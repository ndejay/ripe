module Ripe

  module DB

    ##
    # This class creates and destroys the +Worker+ model in the internal
    # database.

    class WorkerMigration < ActiveRecord::Migration

      ##
      # Create model in database.

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
          t.string  :user
          t.string  :project_name
        end
      end

      ##
      # Destroy model in database.

      def self.down
        drop_table :workers
      end

    end

  end

end
