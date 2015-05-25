module Ripe

  module DB
  
    ##
    # This class creates and destroys the +Task+ model in the internal
    # database.

    class TaskMigration < ActiveRecord::Migration

      ##
      # Create model in database.

      def self.up
        create_table :tasks do |t|
          t.belongs_to :worker
          t.string     :sample
          t.string     :block
        end
      end

      ##
      # Destroy model in database.

      def self.down
        drop_table :tasks
      end

    end
  
  end

end
