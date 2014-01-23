require 'active_record'
require_relative 'task'

class Subtask < ActiveRecord::Base
  belongs_to :task

  def log
    ".ripe/group_#{self.task.group.id}/task_#{self.task.id}/subtask_#{self.id}.log"
  end
end
