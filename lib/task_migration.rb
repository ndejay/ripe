require 'active_record'
require_relative 'group'

class TaskMigration < ActiveRecord::Migration
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
