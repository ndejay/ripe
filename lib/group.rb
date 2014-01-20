require 'active_record'
require 'fileutils'
require_relative 'task'

class Group < ActiveRecord::Base
  has_many :tasks, dependent: :destroy

  def unprepared?
    self.status == :unprepared
  end

  def prepared?
    self.status == :prepared
  end

  def idle?
    self.status == :idle
  end

  def blocked?
    self.status == :blocked
  end

  def active?
    self.status == :active
  end

  def completed?
    self.status == :completed
  end

  def cancelled?
    self.status == :cancelled
  end

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

  def prepare(samples, callback, vars = {})
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

    file = File.new("#{dir}/job.sh", 'w')
    file.puts LiquidBlock.new("#{$RIPE_PATH}/share/moab.sh", vars).command
    file.close

    update(status: :prepared)
  end

  def start!
    raise "Group #{id} could not be started: not prepared" unless self.unprepared?
    start
  end

  def start
    update(status: :idle, moab_id: `msub '#{dir}/job.sh'`.strip)
  end

  def cancel!
    raise "Group #{id} could not be cancelled: not started" unless self.started?
    cancel
  end

  def cancel
    `canceljob #{self.moab_id}`
    update(status: :cancelled)
  end
end
