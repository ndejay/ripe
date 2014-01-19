require 'active_record'
require 'fileutils'
require_relative 'group'

class Task < ActiveRecord::Base
  belongs_to :group

  class Migration < ActiveRecord::Migration
    def self.up
      create_table :tasks do |t|
        t.belongs_to :group
        t.string :sample
        # a block, its vars
      end
    end

    def self.down
      drop_table :tasks
    end
  end

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
