require 'active_record'
require_relative 'task'

module Ripe
  class WorkerMigration < ActiveRecord::Migration
    def self.up
      create_table :workers do |t|
        t.string :handle
        t.string :status, default: :unprepared
        t.string :moab_id
      end
    end

    def self.down
      drop_table :workers
    end
  end
end
