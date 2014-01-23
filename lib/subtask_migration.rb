require 'active_record'
require_relative 'task'

class SubtaskMigration < ActiveRecord::Migration
  def self.up
    create_table :subtasks do |t|
      t.belongs_to :task
      t.string :block
    end
  end

  def self.down
    drop_table :subtasks
  end
end
