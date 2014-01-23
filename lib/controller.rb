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

  def prepare(samples, callback, vars = {})
      Group.prepare(slice_samples, callback, vars)
  end

  def update
    lists = {idle:    '-i',
             blocked: '-b',
             active:  '-r'}.map do |status, op|
      value = `showq -u $(whoami) #{op} | grep $(whoami) | cut -f1 -d' '`
      {status => value.split("\n")}
    end
    
    lists.inject(&:merge).each do |status, moab_ids|
      # Update status
      moab_ids.each do |moab_id|
        group = Group.find_by(moab_id: moab_id)
        group.update(status: status) if group && group.status != 'cancelled'
      end

      # Mark groups that were previously in active, blocked or idle as completed
      # if they cannot be found anymore.
      Group.where(status: status).each do |group|
        group.update(status: :completed) unless moab_ids.include? group.moab_id
      end
    end
  end
end
