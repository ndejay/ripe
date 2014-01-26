require 'active_record'
require 'fileutils'
require_relative 'block'
require_relative 'worker'
require_relative 'worker_migration'
require_relative 'liquid_block'
require_relative 'subtask'
require_relative 'subtask_migration'
require_relative 'task'
require_relative 'task_migration'

module Ripe
  class Controller
    def initialize
      @repository_path = '.ripe'
      @has_repository = Dir.exists? @repository_path
    end

    def attach
      ActiveRecord::Base.establish_connection({
        adapter:  'sqlite3',
        database: "#{@repository_path}/meta.db"
      })
    end

    def attach_or_create
      @has_repository ? attach : create
    end

    def create
      FileUtils.mkdir_p(@repository_path)
      @has_repository = true

      begin
        attach
        WorkerMigration.up
        TaskMigration.up
        SubtaskMigration.up
      rescue
        destroy
      end
    end

    def destroy
      FileUtils.rm_r(@repository_path) if @has_repository
    end

    def prepare(samples, callback, vars = {})
      Worker.prepare(samples, callback, vars)
    end

    def update
      lists = {idle: '-i', blocked: '-b', active:  '-r'}
      lists = lists.map do |status, op|
        value = `showq -u $(whoami) #{op} | grep $(whoami) | cut -f1 -d' '`
        {status => value.split("\n")}
      end

      lists.inject(&:merge).each do |status, moab_ids|
        # Update status
        moab_ids.each do |moab_id|
          worker = Worker.find_by(moab_id: moab_id)
          worker.update(status: status) if worker && worker.status != 'cancelled'
        end

        # Mark workers that were previously in active, blocked or idle as completed
        # if they cannot be found anymore.
        Worker.where(status: status).each do |worker|
          worker.update(status: :completed) unless moab_ids.include? worker.moab_id
        end
      end
    end
  end
end
