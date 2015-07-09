require_relative 'worker_controller/preparer'
require_relative 'worker_controller/syncer'

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
    # @param (see Preparer#initialize)
    # @return [Array<Worker>] workers prepared in current batch

    def prepare(workflow, samples, params = {})
      Preparer.new(workflow, samples, params).workers
    end

    ##
    # Apply a block to a list of workers.
    #
    # @param workers [Array<DB::Worker>, DB::Worker] a list of workers or a
    #   single worker
    # @return [Array<DB::Worker>] the list of workers given in arguments,
    #   with modified states

    def distribute(workers, &block)
      workers = [workers] if workers.is_a? DB::Worker
      workers.map do |w|
        block.call(w)
        w
      end
    end

    ##
    # Run worker job code into bash locally.
    #
    # @param (see #distribute)
    # @return (see #distribute)

    def local(workers)
      distribute workers do |worker|
        `bash #{worker.sh}`
      end
    end

    ##
    # Submit worker jobs to the compute cluster system.
    #
    # @param (see #distribute)
    # @return (see #distribute)

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
    # @param (see #distribute)
    # @return (see #distribute)

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
    #
    # @see Ripe::WorkerController::Syncer
    #
    # @return [Array<DB::Worker>] the list of updated workers

    def sync
      Syncer.new.workers
    end

    ##
    # List the n most recent workers.
    #
    # @param n [Integer] the number of most recent workers
    # @return [Array<DB::Worker>] the list of +n+ most recent workers

    def list(n = 20)
      DB::Worker.last(n)
    end

    ##
    # Launch the an interactive text editor from the console.
    #
    # @return [void]

    def edit(*args)
      system("$EDITOR #{args.join(' ')}")
    end

  end

end
