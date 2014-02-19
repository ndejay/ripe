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

          ## Preorder traversal of blocks -- assign incremental numbers starting from
          ## 1 to each node as it is being traversed.
          post_var_assign = lambda do |subblock|
            if subblock.blocks.length == 0
              subtask = task.subtasks.create(block: subblock.id)
              subblock.vars.merge!(log: subtask.log)
            else
              subblock.blocks.each(&post_var_assign)
            end
          end

          block = callback.call(sample)
          post_var_assign.call(block)
          block
        end

        vars = vars.merge({
          name:    worker.id,
          stdout:  worker.stdout,
          stderr:  worker.stderr,
          command: SerialBlock.new(*blocks).command
        })

        file = File.new(worker.sh, 'w')
        file.puts LiquidBlock.new("#{PATH}/share/moab.sh", vars).command
        file.close

        worker.update(status: :prepared)
        worker
      end
    end

    def self.sync
      lists = {idle: '-i', blocked: '-b', active:  '-r'}
      lists = lists.map do |status, op|
        value = `showq -u $(whoami) #{op} | grep $(whoami) | cut -f1 -d' '`
        {status => value.split("\n")}
      end

      lists.inject(&:merge).each do |status, moab_ids|
        # Update status
        moab_ids.each do |moab_id|
          worker = Worker.find_by(moab_id: moab_id)
          worker.update(status: status) if worker && worker.status != 'cancelled'
        end

        # Mark workers that were previously in active, blocked or idle as completed
        # if they cannot be found anymore.
        Worker.where(status: status).each do |worker|
          worker.update(status: :completed) unless moab_ids.include? worker.moab_id
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
