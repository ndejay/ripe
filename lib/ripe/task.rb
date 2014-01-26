require 'active_record'
require 'fileutils'
require_relative 'worker'

module Ripe
  class Task < ActiveRecord::Base
    belongs_to :worker
    has_many :subtasks, dependent: :destroy

    def dir
      "#{self.worker.dir}/#{self.id}"
    end

    after_create do
      FileUtils.mkdir_p dir if !Dir.exists? dir
    end

    before_destroy do
      FileUtils.rm_r dir if Dir.exists? dir
    end
  end
end
