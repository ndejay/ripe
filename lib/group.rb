require 'active_record'
require 'fileutils'
require_relative 'task'

class Group < ActiveRecord::Base
  has_many :tasks, dependent: :destroy

  def dir
    ".ripe/group_#{self.id}"
  end

  after_create do
    FileUtils.mkdir_p dir # if !Dir.exists? dir
  end

  before_destroy do
    FileUtils.rm_r dir # if Dir.exists? dir
  end

  def prepare!(samples, callback, vars = {})
    raise "Group #{id} could not be prepared: already prepared" unless self.unprepared?
    prepare
  end

  def self.prepare(samples, callback, vars = {})
    vars = {wd: Dir.pwd}.merge(vars)

    samples.each_slice(vars[:group_num]).map do |group_samples|
      group = Group.create(handle: vars[:handle])

      blocks = group_samples.map do |sample|
        task = group.tasks.create(sample: sample)

        # Preorder traversal of blocks -- assign incremental numbers starting from
        # 1 to each node as it is being traversed.
        i, post_var_assign = 0, lambda do |subblock|
          subblock.blocks.length == 0 ?
            subblock.vars.merge!(log: "#{vars[:wd]}/#{task.dir}/#{i += 1}.log") :
          subblock.blocks.each(&post_var_assign)
        end

        block = callback.call(sample)
        post_var_assign.call(block)
        block
      end

      vars = vars.merge({
        name:    group.id,
        stdout:  "#{vars[:wd]}/#{group.dir}/job.stdout",
        stderr:  "#{vars[:wd]}/#{group.dir}/job.stderr",
        command: SerialBlock.new(*blocks).command
      })

      file = File.new("#{vars[:wd]}/#{group.dir}/job.sh", 'w')
      file.puts LiquidBlock.new("#{$RIPE_PATH}/share/moab.sh", vars).command
      file.close

      group.update(status: :prepared)
      group
    end
  end

  def self.list
    self.joins(:tasks).select("*")
  end

  def start!
    raise "Group #{id} could not be started: not prepared" unless self.status == 'prepared'
    start
  end

  def start
    update(status: :idle, moab_id: `msub '#{dir}/job.sh'`.strip)
  end

  def cancel!
    raise "Group #{id} could not be cancelled: not started" unless ['idle', 'blocked', 'active'].include? self.status
    cancel
  end

  def cancel
    `canceljob #{self.moab_id}`
    update(status: :cancelled)
  end
end
