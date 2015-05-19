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
    #
    # @see Ripe::WorkerController::Syncer

    def sync
      Syncer.new
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
