require 'active_record'
require 'fileutils'
require_relative 'block'
require_relative 'group'
require_relative 'group_migration'
require_relative 'liquid_block'
require_relative 'task'
require_relative 'task_migration'

class Controller
  def initialize(wd = "")
    @wd ||= "#{Dir.pwd}"
    @repository_path = "#{@wd}/.ripe"
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
      GroupMigration.up
      TaskMigration.up
    rescue
      destroy
    end
  end

  def destroy
    FileUtils.rm_r(@repository_path) if @has_repository
  end

  def validate_repository
    raise 'fatal: Not a Ripe repository: .ripe' if !@has_repository
  end

  def prepare(samples, callback, vars = {})
    validate_repository

    samples.each_slice(vars[:group_num]).each do |slice_samples|
      group = Group.create(handle: vars[:handle])
      group.prepare(slice_samples, callback, {wd: @wd}.merge(vars))
    end
  end

  def start(handle)
    validate_repository

    Group.where(handle: handle, status: 'prepared').each(&:start)
  end

  def list(handle, statuses: ['prepared', 'started', 'cancelled'])
    validate_repository

    $stdout.puts "Handle\tID\tStatus\tMoab ID\tSamples"
    statuses.each do |status|
      Group.where(handle: handle, status: status).each do |group|
        $stdout.puts "#{group.handle}\t#{group.id}\t#{group.status}\t#{group.moab_id}\t#{group.samples}"
      end
    end
  end

  def cancel(handle)
    validate_repository

    Group.where(handle: handle, status: 'started').each(&:cancel)
  end

  def remove(handle, statuses = ['prepared', 'cancelled'])
    validate_repository

    statuses.each do |status|
      Group.where(handle: handle, status: status).each(&:destroy)
    end
  end
end
