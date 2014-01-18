require 'active_record'
require_relative 'task'

class Group < ActiveRecord::Base
  has_many :tasks, dependent: :destroy

  class Migration < ActiveRecord::Migration
    def self.up
      create_table :groups do |t|
        t.string :handle
        t.string :status
        t.string :moab_id
      end
    end

    def self.down
      drop_table :groups
    end
  end
end
