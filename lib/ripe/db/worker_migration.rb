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
          t.string  :handle
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
