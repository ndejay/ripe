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
    Group.where(handle: handle, status: :prepared).each(&:start)
  end

  def update
    validate_repository

    lists = {idle: '-i', blocked: '-b', active: '-r'}.map do |status, op|
      value = `showq -u $(whoami) #{op} -n | grep $(whoami) | cut -f1 -d' '`
      {status => value.split("\n").map(&:to_i)}
    end
    
    lists.inject(&:merge).each do |status, ids|
      # Update status
      ids.each do |id|
        group = Group.find(id)
        group.update(status: status) unless group.cancelled?
      end

      # Mark groups that were previously in active, blocked or idle as completed
      # if they cannot be found anymore.
      Group.where(status: status).each do |group|
        group.update(status: :completed) unless ids.include? group.id
      end
    end

    nil
  end

  def list(handle: nil, statuses: [:unprepared, :prepared, :idle, :blocked, :active,
                                   :completed, :cancelled])
    validate_repository
    output = "Handle\tID\tStatus\tMoabID\tSamples\n"
    output << statuses.flat_map { |status|
      filter = handle ? Group.where(handle: handle) : Group
      filter.where(status: status).map do |group|
        [group.handle, group.id, group.status,
         group.moab_id ? group.moab_id : "NA",
         group.tasks.pluck(:sample)].join("\t")
      end
    }.join("\n")
    puts `echo -e "#{output}" | column -t`
  end

  def cancel(handle)
    validate_repository
    Group.where(handle: handle).select(&:started?).each(&:cancel)
  end

  def remove(handle, statuses = [:prepared, :cancelled])
    validate_repository
    statuses.flat_map do |status|
      Group.where(handle: handle, status: status).each(&:destroy)
    end
  end
end
