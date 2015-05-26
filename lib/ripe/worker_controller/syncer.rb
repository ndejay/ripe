module Ripe

  class WorkerController

    ##
    # This class controls worker syncing with the compute cluster.
    #
    # @see Ripe::WorkerController#sync

    class Syncer

      ##
      # Synchronize the status of jobs with the internal list of workers.

      def initialize
        running_jobs = list_running_jobs
        update_running_workers(running_jobs)
        update_completed_workers(running_jobs.map { |job| job[:moab_id] })
      end

      ##
      # Retrieve status for all running jobs.
      #
      # @return [Array] a list of job statuses (+moab_id+, +time+ and +status+)

      def list_running_jobs
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
        lists.inject(&:+)
      end

      ##
      # Update the status of running jobs.
      #
      # @param running_jobs [Array] a list of running jobs

      def update_running_workers(running_jobs)
        # Update status
        running_jobs.each do |job|
          moab_id   = job[:moab_id]
          time      = job[:time]
          status    = job[:status]
          worker    = DB::Worker.find_by(moab_id: moab_id)

          if worker
            worker.update(time: time)
            unless ['cancelled', status].include?(worker.status)
              checkjob = `checkjob #{moab_id}`
              worker.update({
                host:      checkjob[/Allocated Nodes:\n\[(.*):[0-9]+\]\n/, 1],
                status:    status, # Queued jobs that appear become either idle, blocked or active
              })
            end
          end
        end
      end

      ##
      # Update the status of completed jobs.  Mark workers that were previously
      # in active, blocked or idle as completed if they cannot be found in the
      # queue of the compute cluster engine.
      #
      # @param running_job_ids [Array] a list of running job ids

      def update_completed_workers(running_job_ids)
        DB::Worker.where('status in (:statuses)',
                         :statuses => ['active', 'idle', 'blocked']).each do |worker|
          if running_job_ids.include?(worker.moab_id)
            running_job_ids.delete(worker.moab_id) # Remove from list
          elsif (worker.status != 'cancelled')
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

end
