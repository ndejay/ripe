module Ripe

  ##
  # This class represents a +Task+ object, the equivalent of a terminal
  # +Block+ in ripe's internal representation of workflows.  Instances of
  # this classes are used exclusively by +WorkerController+.
  #
  # @see Ripe::WorkerController

  class Task

    def initialize(sample, block, id, parent_worker)
      @sample = sample
      @id = id
      @block = block
      @parent_worker = parent_worker
    end

    ##
    # Return path to task directory, which is the same as worker directory.

    def dir
      "#{@parent_worker.dir}.#{@id}"
    end

    ##
    # Return path to task-level combined shell script, +stdout+ and +stderr+ log.

    def log
      "#{self.dir}.log"
    end

  end

end
