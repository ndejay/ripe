require 'active_record'
require 'fileutils'
require_relative 'block'
require_relative 'group'
require_relative 'liquid_block'
require_relative 'task'

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
      Group::Migration.up
      Task::Migration.up
    rescue
      destroy
    end
  end

  def destroy
    FileUtils.rm_r(@repository_path) if @has_repository
  end

  def prepare(samples, callback, vars = {})
    raise 'fatal: Not a Ripe repository: .ripe' if !@has_repository

    vars[:group_num] ||= 1
    vars[:wd] ||= @wd

    samples.each_slice(vars[:group_num]).each do |slice_samples|
      # Record
      group = Group.create(handle: vars[:handle])

      # Processing
      group_dir = "#{@repository_path}/group_#{group.id}"
      group_blocks = slice_samples.map do |sample|
        task = group.tasks.create(sample: sample)
        task_dir = "#{group_dir}/task_#{task.id}"
        task_block = callback.call(sample)

        FileUtils.mkdir_p(task_dir)

        # Preorder traversal of blocks -- assign incremental numbers starting from
        # 1 to each node as it is being traversed.
        i, post_var_assign = 0, lambda do |block|
          block.blocks.length == 0 ?
            block.vars.merge!(log: "#{task_dir}/#{i += 1}.log") :
          block.blocks.each(&post_var_assign)
        end
        post_var_assign.call(task_block)

        task_block
      end

      group_vars = vars.merge({
        name:    group.id,
        stdout:  "#{group_dir}/job.stdout",
        stderr:  "#{group_dir}/job.stderr",
        command: SerialBlock.new(*group_blocks).command
      }) # _ > vars

      # Job file
      file = File.new("#{group_dir}/job.sh", 'w')
      file.puts LiquidBlock.new("#{$RIPE_PATH}/moab.sh", group_vars).command
      file.close
    end
  end
end
