require 'active_record'
require 'fileutils'
require_relative 'group'

class Task < ActiveRecord::Base
  belongs_to :group
  has_many :subtasks, dependent: :destroy

  def dir
    ".ripe/group_#{self.group_id}/task_#{self.id}"
  end

  after_create do
    FileUtils.mkdir_p dir if !Dir.exists? dir
  end

  before_destroy do
    FileUtils.rm_r dir if Dir.exists? dir
  end
end
