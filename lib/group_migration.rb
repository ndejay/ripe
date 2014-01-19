require 'active_record'
require_relative 'task'

class GroupMigration < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :handle
      t.string :status, :default => 'unprepared'
      t.string :moab_id, :default => nil
    end
  end

  def self.down
    drop_table :groups
  end
end
