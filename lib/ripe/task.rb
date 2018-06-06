module Ripe

  ##
  # This class represents a +Task+ object, the equivalent of a terminal
  # +Block+ in ripe's internal representation of workflows.  Instances of
  # this classes are used exclusively by +WorkerController+.
  #
  # @see Ripe::WorkerController

  class Task

    def initialize(sample, block, id, parent_worker, handle)
      @sample = sample
      @id = id
      @handle = handle
      @block = block
      @parent_worker = parent_worker
    end

    ##
    # Return path to task directory, which is the same as worker directory.

    def dir
      "#{@parent_worker.dir}__#{@sample}__#{@id.to_s.rjust(3, "0")}:#{@handle}"
    end

    ##
    # Return path to task-level combined shell script, +stdout+ and +stderr+ log.

    def log
      "#{self.dir}.log"
    end

  end

end
