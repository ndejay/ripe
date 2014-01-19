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

  def update
    validate_repository

    # This method can use some optimization.

    sections = {
      'active'  => `showq -u $(whoami) -r -n | grep $(whoami) | cut -f1 -d' '`,
      'idle'    => `showq -u $(whoami) -i -n | grep $(whoami) | cut -f1 -d' '`,
      'blocked' => `showq -u $(whoami) -b -n | grep $(whoami) | cut -f1 -d' '` 
    }

    sections.each do |status, jobs|
      jobs.split('\n').each do |job|
        group = Group.find(job)
        if group && group.status != 'cancelled'
          group.status = status
          group.save
        end
      end
    end

    Group.where(status: 'active').each do |group|
      if !sections['active'].include? group.id
        group.status = 'completed'
        group.save
      end
    end
  end

  def list(handle, statuses: ['unprepared', 'prepared', 'idle', 'blocked',
                              'active', 'completed', 'cancelled'])
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

    statuses = ['idle', 'blocked', 'active']
    statuses.each do |status|
      Group.where(handle: handle, status: status).each(&:cancel)
    end
  end

  def remove(handle, statuses = ['prepared', 'cancelled'])
    validate_repository

    statuses.each do |status|
      Group.where(handle: handle, status: status).each(&:destroy)
    end
  end
end
