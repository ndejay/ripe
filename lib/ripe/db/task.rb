module Ripe

  module DB

    ##
    # This class represents a +Task+ object in ripe's internal database.
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
      # Return path to task-level combined +stdout+ and +stderr+ log.

      def log
        "#{self.dir}.log"
      end

      ##
      # Return path to task-level job script, which only includes the task at
      # hand.  This script is never actually executed by ripe.
      #
      # @see Ripe::DB::Worker#sh

      def sh
        "#{self.dir}.sh"
      end

    end

  end

end
