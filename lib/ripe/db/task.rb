module Ripe

  module DB

    ##
    # This class represents a +Task+ object in ripe's internal database. Its
    # fields are defined by +Ripe::DB::TaskMigration+.
    #
    # @see Ripe::WorkerController

    class Task < ActiveRecord::Base
      belongs_to :worker

      ##
      # Return path to task directory, which is the same as worker directory.

      def dir
        "#{self.worker.dir}"
      end

      ##
      # Return path to task-level combined +stdout+ and +stderr+ log.

      def log
        "#{self.dir}/#{self.id}.log"
      end

      ##
      # Return path to task-level job script, which only includes the task at
      # hand.  This script is never actually executed by ripe.
      #
      # @see Ripe::DB::Worker#sh

      def sh
        "#{self.dir}/#{self.id}.sh"
      end

    end

  end

end
