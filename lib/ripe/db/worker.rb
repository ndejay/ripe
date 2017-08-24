module Ripe

  module DB

    ##
    # This class represents a +Worker+ object in ripe's internal database. Its
    # fields are defined by +Ripe::DB::WorkerMigration+.
    #
    # @see Ripe::WorkerController

    class Worker < ActiveRecord::Base
      has_many :tasks, dependent: :destroy

      ##
      # Return path to worker directory

      def dir
        "#{self.output_prefix}.#{self.id}"
      end

      ##
      # Return path to worker/job script, which includes all tasks defined in
      # the worker.  This is the script that is actually executed when the
      # worker is run.
      #
      # @see Ripe::DB::Task#sh

      def sh
        "#{self.dir}.job.sh"
      end

      ##
      # Return path to the +stdout+ output of the job, which only exists after
      # the job has been completed.

      def stdout
        "#{self.dir}.job.stdout"
      end

      ##
      # Return path to the +stderr+ output of the job, which only exists after
      # the job has been completed.

      def stderr
        "#{self.dir}.job.stderr"
      end

    end

  end

end
