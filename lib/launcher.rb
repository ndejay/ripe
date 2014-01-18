require 'fileutils'
require 'pathname'
require_relative 'block'
require_relative 'database'
require_relative 'liquid_block'

class Launcher
  def initialize(callback, vars = {})
    @callback, @vars = callback, vars
  end

  def run(samples, post_vars = {})
    Database.connect
    Database.create

    # By default, use current working directory
    @vars = { wd: Dir.pwd }.merge(@vars.merge(post_vars)) # post_vars > @vars > {}
    group_num = post_vars[:group_num] || 1

    samples.each_slice(group_num).each do |slice_samples|
      # Record
      group = Group.create(handle: @vars[:handle])

      # Processing
      group_dir = "#{@vars[:wd]}/.ripe/group_#{group.id}"
      group_blocks = slice_samples.map do |sample|
        task = group.tasks.create(sample: sample)
        task_dir = "#{group_dir}/task_#{task.id}"
        task_block = @callback.call(sample)

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
      group_vars = @vars.merge({
        name:    group.id,
        stdout:  "#{group_dir}/job.stdout",
        stderr:  "#{group_dir}/job.stderr",
        command: SerialBlock.new(*group_blocks).command
      })# vars > @vars

      # Job file
      file = File.new("#{group_dir}/job.sh", 'w')
      file.puts LiquidBlock.new("#{$RIPE_PATH}/moab.sh", group_vars).command
      file.close
    end
  end
end
