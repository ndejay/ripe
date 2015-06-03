module Ripe

  class WorkerController

    ##
    # This class controls worker syncing with the compute cluster queue.
    #
    # @attr_reader running_jobs [Array<Hash<Symbol, String>>] a list of running
    #   jobs as well as certain parameters (+moab_id+, +time+ and +status).
    # @attr_reader completed_jobs [Array<DB::Worker>] a list of completed
    #   workers
    # @attr_reader workers [Array<DB::Worker>] list of workers that have been
    #   updated (or completed)
    #
    # @see Ripe::WorkerController#sync

    class Syncer

      attr_reader :running_jobs, :completed_jobs, :workers

      ##
      # Synchronize the status of jobs with the internal list of workers.

      def initialize
        @workers = []

        fetch_running_jobs
        update_running_workers
        fetch_completed_jobs
        update_completed_workers
      end

      ##
      # Fetch status for all running jobs.
      #
      # @return [void]

      def fetch_running_jobs
        lists = {idle: '-i', blocked: '-b', active:  '-r'}
        lists = lists.map do |status, op|
          showq = `showq -u $(whoami) #{op} | grep $(whoami)`.split("\n")
          showq.map do |job|
            {
              moab_id:   job[/^([0-9]+) /, 1],
              time:      job[/  ([0-9]{1,2}(\:[0-9]{2})+)  /, 1],
              status:    status,
            }
          end
        end
        @running_jobs = lists.inject(&:+)
      end

      ##
      # Update the status of running workers from the running jobs.
      #
      # @return [void]

      def update_running_workers
        @workers += @running_jobs.map do |job|
          worker = DB::Worker.find_by(moab_id: job[:moab_id])
          if worker
            worker.update(time: job[:time])
            unless ['cancelled', job[:status]].include?(worker.status)
              checkjob = `checkjob #{job[:moab_id]}`
              worker.update({
                host:      checkjob[/Allocated Nodes:\n\[(.*):[0-9]+\]\n/, 1],
                # Queued jobs that appear become either idle, blocked or active
                status:    job[:status],
              })
            end
          end
          worker
        end
      end

      ##
      # Fetch a list of completed workers from the running jobs: these are jobs
      # that were previously marked as active, blocked or idle that can no
      # be found on the compute cluster queue.
      #
      # @return [void]

      def fetch_completed_jobs
        running_job_ids = @running_jobs.map { |job| job[:moab_id] }

        running_workers = DB::Worker.where('status in (:statuses)',
                                           :statuses => ['active', 'idle', 'blocked'])

        @completed_workers = running_workers.select do |worker|
          !running_job_ids.include?(worker.moab_id) &&
            worker.status != 'cancelled'
        end
      end

      ##
      # Update the status of completed workers from the running jobs.
      #
      # @return [void]

      def update_completed_workers
        @workers += @completed_workers.map do |worker|
          stdout = (File.exists?(worker.stdout)) ? File.new(worker.stdout).readlines.join : ""
          worker.update({
            cpu_used:    stdout[/Resources:[ \t]*cput=([0-9]{1,2}(\:[0-9]{2})+),/, 1],
            exit_code:   stdout[/Exit code:[ \t]*(.*)$/, 1],
            host:        stdout[/Nodes:[ \t]*(.*)$/, 1],
            memory_used: stdout[/Resources:.*,mem=([0-9]*[a-zA-Z]*),/, 1],
            time:        stdout[/Resources:.*,walltime=([0-9]{1,2}(\:[0-9]{2})+)$/, 1],
            status:      :completed,
          })
        end
      end

    end

  end

end
