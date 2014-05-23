require 'active_record'
require 'fileutils'
require_relative 'subtask'
require_relative 'task'

module Ripe
  class Worker < ActiveRecord::Base
    has_many :tasks, dependent: :destroy
    has_many :subtasks, through: :tasks

    def dir
      ".ripe/#{self.id}"
    end

    def sh
      "#{self.dir}/job.sh"
    end

    def stdout
      "#{self.dir}/job.stdout"
    end

    def stderr
      "#{self.dir}/job.stderr"
    end

    after_create do
      FileUtils.mkdir_p dir # if !Dir.exists? dir
    end

    before_destroy do
      FileUtils.rm_r dir # if Dir.exists? dir
    end

    def self.prepare(samples, callback, vars = {})
      vars = {wd: Dir.pwd}.merge(vars)

      samples.each_slice(vars[:worker_num]).map do |worker_samples|
        worker = Worker.create(handle: vars[:handle])

        blocks = worker_samples.map do |sample|
          task = worker.tasks.create(sample: sample)
          block = callback.call(sample).prune(false)

          if block != nil
            # Preorder traversal of blocks -- assign incremental numbers starting from
            # 1 to each node as it is being traversed.
            post_var_assign = lambda do |subblock|
              if subblock.blocks.length == 0
                subtask = task.subtasks.create(block: subblock.id)
                subblock.vars.merge!(log: subtask.log)
              else
                subblock.blocks.each(&post_var_assign)
              end
            end

            puts "Preparing #{sample} (worker #{worker.id})"
            post_var_assign.call(block)
          else
            puts "Nothing to do for sample #{sample} (worker #{worker.id})"
            task.destroy
          end

          block
        end

        blocks = blocks.reject { |block| block == nil }

        if blocks.empty?
          puts "Nothing to do for worker #{worker.id}"
          worker.destroy
          nil
        else
          puts "Preparing worker #{worker.id}"

          vars = vars.merge({
            name:    worker.id,
            stdout:  worker.stdout,
            stderr:  worker.stderr,
            command: SerialBlock.new(*blocks).command,
          })

          file = File.new(worker.sh, 'w')
          file.puts LiquidBlock.new("#{PATH}/share/moab.sh", vars).command
          file.close

          worker.update({
            status:   :prepared,
            ppn:      vars[:ppn],
            queue:    vars[:queue],
            walltime: vars[:walltime],
          })
          worker
        end
      end
    end

    def self.sync
      lists = {idle: '-i', blocked: '-b', active:  '-r'}
      lists = lists.map do |status, op|
        showq = `showq -u $(whoami) #{op} | grep $(whoami)`.split("\n")
        showq.map do |job|
          {
            moab_id:   job[/^([0-9]+) /, 1],
            time:      job[/  ([0-9]{1,2}(\:[0-9]{2})+)  /, 1],
            status:    status,
          }
        end
      end

      # Update status
      lists = lists.inject(&:+).each do |job|
        moab_id   = job[:moab_id]
        time      = job[:time]
        status    = job[:status]
        worker    = Worker.find_by(moab_id: moab_id)

        if worker
          worker.update(time: time)
          unless ['cancelled', status].include? worker.status
            checkjob = `checkjob #{moab_id}`
            worker.update({
              host:      checkjob[/Allocated Nodes:\n\[(.*):[0-9]+\]\n/, 1],
              status:    status,
            })
          end
        end
      end

      # Mark workers that were previously in active, blocked or idle as completed
      # if they cannot be found anymore.
      jobs = lists.map { |job| job[:moab_id] }
      Worker.where('status in (:statuses)',
                   :statuses => ['active', 'idle', 'blocked']).each do |worker|
        if jobs.include? worker.moab_id
          jobs.delete(worker.moab_id)
        elsif (worker.status != 'cancelled')
          if File.exists? worker.stdout
            stdout = File.new(worker.stdout).readlines.join 
          else
            stdout = ""
          end
          worker.update({
            cpu_used:    stdout[/Resources:[ \t]*cput=([0-9]{1,2}(\:[0-9]{2})+),/, 1],
            exit_code:   stdout[/Exit code:[ \t]*(.*)$/, 1],
            host:        stdout[/Nodes:[ \t]*(.*)$/, 1],
            memory_used: stdout[/Resources:.*,mem=([0-9]*[a-zA-Z]*),/, 1],
            time:        stdout[/Resources:.*,walltime=([0-9]{1,2}(\:[0-9]{2})+)$/, 1],
            status:      :completed,
          })
        end
      end
    end

    def start!
      raise "Worker #{id} could not be started: not prepared" unless self.status == 'prepared'
      start
    end

    def start
      update(status: :idle, moab_id: `msub '#{self.sh}'`.strip)
    end

    def cancel!
      raise "Worker #{id} could not be cancelled: not started" unless ['idle', 'blocked', 'active'].include? self.status
      cancel
    end

    def cancel
      `canceljob #{self.moab_id}`
      update(status: :cancelled)
    end
  end
end
