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
        "#{Repo::REPOSITORY_PATH}/workers/#{self.id}"
      end

      ##
      # Return path to worker/job script, which includes all tasks defined in
      # the worker.  This is the script that is actually executed when the
      # worker is run.
      #
      # @see Ripe::DB::Task#sh

      def sh
        "#{self.dir}/job.sh"
      end

      ##
      # Return path to the +stdout+ output of the job, which only exists after
      # the job has been completed.

      def stdout
        "#{self.dir}/job.stdout"
      end

      ##
      # Return path to the +stderr+ output of the job, which only exists after
      # the job has been completed.

      def stderr
        "#{self.dir}/job.stderr"
      end

      # Automatically create worker directory upon object instantiation

      after_create do
        FileUtils.mkdir_p dir if !Dir.exists? dir
      end

      # Automatically remove worker directory upon object destruction

      before_destroy do
        FileUtils.rm_r dir if Dir.exists? dir
      end

      # Automatically create accessors for `#status`.
      #
      #     worker.status == :prepared
      #
      # becomes
      #
      #     worker.prepared?

      [:unprepared, :prepared, :queueing, :idle,
       :blocked, :active, :active_local, :cancelled, :completed].map do |s|
        define_method("#{s}?") { status.to_s == s.to_s }
      end
    end

  end

end
