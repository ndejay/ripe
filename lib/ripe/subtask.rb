require 'active_record'
require_relative 'task'

module Ripe
  class Subtask < ActiveRecord::Base
    belongs_to :task

    def log
      "#{self.task.dir}/#{self.id}.log"
    end
  end
end
