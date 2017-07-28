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
        worker.update(status: :active_local)

        `bash #{worker.sh}`
        exit_code = $?.to_i

        worker.update(status:    :completed,
                      exit_code: exit_code)
      end
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
