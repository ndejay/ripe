require_relative 'task'

module Ripe
  module DB
    class WorkerMigration < ActiveRecord::Migration
      def self.up
        create_table :workers do |t|
          t.string  :cpu_used
          t.string  :exit_code
          t.string  :handle
          t.string  :host
          t.string  :moab_id
          t.string  :memory_used
          t.integer :ppn
          t.string  :queue
          t.string  :time
          t.string  :status, default: :unprepared
          t.string  :walltime
        end
      end

      def self.down
        drop_table :workers
      end
    end
  end
end
