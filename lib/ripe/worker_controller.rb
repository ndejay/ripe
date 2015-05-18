require_relative 'worker_controller/preparer'

module Ripe

  ##
  # This class controls workers as well as their relationship with regards to
  # the compute cluster: worker preparation, submission, cancellation as well
  # as sync.

  class WorkerController

    ##
    # Prepare workers by applying the workflow callback and its parameters to
    # each sample.
    #
    # @see Ripe::DSL::WorkflowDSL#describe
    # @see Ripe::WorkerController::Preparer
    #
    # @param workflow [String] the name of a workflow to apply on the sample
    #   list
    # @param samples [Array] list of samples to apply the callback to
    # @param params [Hash] a list of worker-wide parameters

    def prepare(workflow, samples, params = {})
      Preparer.new(workflow, samples, params)
    end

    ##
    #

    def distribute(workers, &block)
      workers = [workers] if workers.is_a? DB::Worker
      workers.map { |w| block.call(w) }
    end

    ##
    # Run worker job code into bash locally.
    #
    # @param workers [Array] a list of workers

    def local(workers)
      distribute workers do |worker|
        `bash #{worker.sh}`
      end
    end

    ##
    # Submit worker jobs to the compute cluster system.
    #
    # @param workers [Array] a list of workers

    def start(workers)
      distribute workers do |worker|
        if worker.status == 'prepared'
          worker.update(status: :queueing,
                        moab_id: `qsub '#{worker.sh}'`.strip.split(/\./).first)
        else
          puts "Worker #{worker.id} could not be started: not prepared"
        end
      end
    end

    ##
    # Cancel worker jobs in the compute cluster system.
    #
    # @param workers [Array] a list of workers

    def cancel(workers)
      distribute workers do |worker|
        if ['queueing', 'idle', 'blocked', 'active'].include? worker.status
          `canceljob #{worker.moab_id}`
          worker.update(status: :cancelled)
        else
          puts "Worker #{worker.id} could not be cancelled: not started"
        end
      end
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
        worker    = DB::Worker.find_by(moab_id: moab_id)

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
      DB::Worker.where('status in (:statuses)',
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

    ##
    # List the n most recent workers
    #
    # @param n [Integer] the number of most recent workers to keep

    def list(n = 20)
      DB::Worker.last(n)
    end

    ##
    # Launch the an interactive text editor from the console

    def edit(*args)
      system("$EDITOR #{args.join(' ')}")
    end

  end

end
