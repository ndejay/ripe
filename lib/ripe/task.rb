require 'active_record'
require 'fileutils'
require_relative 'worker'

module Ripe
  class Task < ActiveRecord::Base
    belongs_to :worker

    def dir
      "#{self.worker.dir}"
    end

    def log
      "#{self.dir}/#{self.id}.log"
    end
  end
end
