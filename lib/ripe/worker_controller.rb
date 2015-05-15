require 'singleton'
require_relative 'worker'

module Ripe

  ##
  # This class controls workers as well as their relationship with regards to
  # the compute cluster: worker preparation, submission, cancellation as well
  # as sync.

  class WorkerController

    include Singleton

    ##
    # Prepares workers by applying the workflow callback and its parameters to
    # each sample.
    #
    # @see Ripe::DSL::WorkflowDSL#describe
    #
    # @param samples [List] list of samples to apply the callback to
    # @param callback [Proc] a callback function that takes as arguments the name
    #   of sample and a hash of parameters provided by the workflow and by the
    #   command line.
    # @param vars [Hash] a list of worker-wide parameters

    def prepare(samples, callback, vars = {})
      vars = {
        wd:        Dir.pwd,
        mode:      :patch,
        group_num: 1,
      }.merge(vars)

      return if ![:patch, :force, :depend].include? vars[:mode].to_sym

      samples = samples.map do |sample|
        block = callback.call(sample, vars).prune(vars[:mode].to_sym == :force,
                                                  vars[:mode].to_sym == :depend)
        if block != nil
          puts "Preparing sample #{sample}"
          [sample, block]
        else
          puts "Nothing to do for sample #{sample}"
          nil
        end
      end
      samples = samples.compact

      samples.each_slice(vars[:group_num].to_i).map do |worker_samples|
        worker = Worker.create(handle: vars[:handle])

        blocks = worker_samples.map do |sample, block|
          # Preorder traversal of blocks -- assign incremental numbers starting from
          # 1 to each node as it is being traversed, as well as producing the job
          # file for each task.
          post_var_assign = lambda do |subblock|
            if subblock.blocks.length == 0
              # This section is only called when the subblock is actually a working
              # block (a leaf in the block arborescence).
              task = worker.tasks.create({
                sample: sample,
                block:  subblock.id,
              })

              file = File.new(task.sh, 'w')
              file.puts subblock.command
              file.close

              subblock.vars.merge!(log: task.log)
            else
              subblock.blocks.each(&post_var_assign)
            end
          end

          post_var_assign.call(block)
          block
        end

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

    ##
    # Submit a job to the compute cluster system
    #
    # @param worker [Worker] the worker to submit

    def start(worker)
      worker.update(status: :queueing,
                    moab_id: `qsub '#{worker.sh}'`.strip.split(/\./).first)
    end

    ##
    # Cancel a job in the compute cluster system
    #
    # @param worker [Worker] the worker to cancel

    def cancel(worker)
      `canceljob #{worker.moab_id}`
      worker.update(status: :cancelled)
    end

    ##
    # Synchronize the status of jobs with the internal list of workers.

    def sync
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
              status:    status, # Queued jobs that appear become either idle, blocked or active
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
          jobs.delete(worker.moab_id) # Remove from list
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

    def list(n = 20)
      Worker.last(n)
    end

    def edit(*args)
      system("$EDITOR #{args.join(' ')}")
    end

  end

end
