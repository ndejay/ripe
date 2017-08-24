module Ripe

  module DB

    ##
    # This class represents a +Worker+ object in ripe's internal database.
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
      # @see Ripe::DB::Task#sh

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

end
