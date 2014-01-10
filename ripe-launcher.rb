require 'fileutils'
require 'pathname'
require 'ripe-block'
require 'ripe-liquid_block'

class Launcher
  def initialize(callback, vars = {})
    @callback, @vars = callback, vars
  end

  def process_job(samples)
    id = samples.join('.')
    dir = "#{@vars[:wd]}/.ripe/#{@vars[:handle]}/#{id}"
    root = SerialBlock.new(*samples.collect(&@callback))
    
    # Preorder traversal of blocks -- assign incremental numbers starting from
    # 1 to each node as it is being traversed.
    i, post_var_assign = 0, lambda { |block|
      block.blocks.length == 0 ?
        block.vars.merge!({ log: "#{dir}/#{i += 1}.log" }) :
        block.blocks.each(&post_var_assign)
    }
    post_var_assign.call(root)

    vars = @vars.merge({
      name:    id,
      stdout:  "#{dir}/job.stdout",
      stderr:  "#{dir}/job.stderr",
      command: root.command
    }) # vars > @vars
    
    # Directory
    FileUtils.mkdir_p(dir)

    # Job file
    filename = "#{dir}/job.sh"
    file = File.new("#{dir}/job.sh", 'w')
    file.puts LiquidBlock.new("#{Pathname.new(__FILE__).dirname}/ripe-moab.sh", vars).command
    file.close

    puts filename
  end

  def run(samples, post_vars = {})
    # By default, use current working directory
    @vars = { wd: Dir.pwd }.merge(@vars.merge(post_vars)) # post_vars > @vars > {}
    group_num = post_vars[:group_num] || 1

    samples.each_slice(group_num).each { |slice| process_job(slice) }
  end

  private :process_job
end
