require 'active_record'
require_relative 'group'
require_relative 'task'

class Database
  def self.connect
    FileUtils.mkdir_p("#{Dir.pwd}/.ripe")
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => '.ripe/meta.db'
    )
  end

  def self.create
    models = {
      :groups => Group,
      :tasks => Task
    }

    models.each do |k, v|
      unless ActiveRecord::Base.connection.table_exists? k
        v::Migration.up
      end
    end
  end
end
