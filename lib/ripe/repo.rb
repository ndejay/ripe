require 'active_record'
require 'fileutils'
require_relative 'block'
require_relative 'worker'
require_relative 'worker_controller'
require_relative 'worker_migration'
require_relative 'working_block'
require_relative 'library'
require_relative 'liquid_block'
require_relative 'task'
require_relative 'task_migration'

module Ripe
  class Repo
    REPOSITORY_PATH = '.ripe'
    DATABASE_PATH   = "#{REPOSITORY_PATH}/meta.db"
    WORKERS_PATH    = "#{REPOSITORY_PATH}/workers"

    attr_reader :library, :controller

    def initialize
      @has_repository = File.exists? REPOSITORY_PATH
      @library        = Library.new
      @controller     = WorkerController.instance
    end

    def attach
      ActiveRecord::Base.establish_connection({
        adapter:  'sqlite3',
        database: DATABASE_PATH,
      })
    end

    def attach_or_create
      @has_repository ? attach : create
    end

    def create
      FileUtils.mkdir_p(REPOSITORY_PATH)
      @has_repository = true

      begin
        attach
        WorkerMigration.up
        TaskMigration.up
      rescue
        destroy
      end
    end

    def destroy
      FileUtils.rm(DATABASE_PATH) if File.exists? DATABASE_PATH
      FileUtils.rm(WORKERS_PATH)  if Dir.exists?  WORKERS_PATH
    end

    def prepare(samples, callback, vars = {})
      @controller.prepare(samples, callback, vars)
    end
  end
end
