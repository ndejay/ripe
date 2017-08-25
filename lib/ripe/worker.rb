module Ripe

  ##
  # This class represents a +Worker+ object, the equivalent of a top-level
  # block in ripe's internal representation of a workflow applied to one or
  # more samples.  Instances of this classes are used exclusively by
  # +WorkerController+.
  #
  # @see Ripe::WorkerController

  class Worker

    attr_accessor :tasks
    attr_accessor :id

    def initialize(handle, id, output_prefix)
      @handle = handle
      @id = id
      @output_prefix = output_prefix
      @tasks = []
    end

    ##
    # Return path to worker directory

    def dir
      "#{@output_prefix}.#{@id}"
    end

    ##
    # Return path to worker/job script, which includes all tasks defined in
    # the worker.  This is the script that is actually executed when the
    # worker is run.
    #
    # @see Ripe::Task#sh

    def sh
      "#{dir}.job.sh"
    end

    ##
    # Return path to the +stdout+ output of the job, which only exists after
    # the job has been completed.

    def stdout
      "#{dir}.job.stdout"
    end

    ##
    # Return path to the +stderr+ output of the job, which only exists after
    # the job has been completed.

    def stderr
      "#{dir}.job.stderr"
    end

  end

end
