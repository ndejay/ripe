require 'active_record'
require 'fileutils'
require_relative 'task'

class Group < ActiveRecord::Base
  has_many :tasks, dependent: :destroy

  def dir
    ".ripe/group_#{self.id}"
  end

  def samples
    self.tasks.map { |task| task.sample }
  end

  after_create do
    FileUtils.mkdir_p dir if !Dir.exists? dir
  end

  before_destroy do
    FileUtils.rm_r dir if Dir.exists? dir
  end

  def prepare(samples, callback, vars = {})
    # if group.status == 'unprepared'
    blocks = samples.map do |sample|
      task = self.tasks.create(sample: sample)

      # Preorder traversal of blocks -- assign incremental numbers starting from
      # 1 to each node as it is being traversed.
      i, post_var_assign = 0, lambda do |subblock|
        subblock.blocks.length == 0 ?
          subblock.vars.merge!(log: "#{task.dir}/#{i += 1}.log") :
        subblock.blocks.each(&post_var_assign)
      end

      block = callback.call(sample)
      post_var_assign.call(block)
      block
    end

    vars = vars.merge({
      name:    self.id,
      stdout:  "#{dir}/job.stdout",
      stderr:  "#{dir}/job.stderr",
      command: SerialBlock.new(*blocks).command
    }) 

    # Job file
    file = File.new("#{dir}/job.sh", 'w')
    file.puts LiquidBlock.new("#{$RIPE_PATH}/moab.sh", vars).command
    file.close

    self.status = 'prepared'
    self.save
  end

  def start
    # if group.status == 'prepared'
    self.moab_id = `msub '#{dir}/job.sh'`.strip
    self.status = 'started'
    self.save
  end

  def cancel
    # if self.moab_id
    `canceljob #{self.moab_id}`
    self.status = 'cancelled'
    self.save
  end
end
