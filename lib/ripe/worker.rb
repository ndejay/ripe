require 'active_record'
require 'fileutils'
require_relative 'task'

module Ripe
  class Worker < ActiveRecord::Base
    has_many :tasks, dependent: :destroy

    def dir
      ".ripe/workers/#{self.id}"
    end

    def sh
      "#{self.dir}/job.sh"
    end

    def stdout
      "#{self.dir}/job.stdout"
    end

    def stderr
      "#{self.dir}/job.stderr"
    end

    after_create do
      FileUtils.mkdir_p dir if !Dir.exists? dir
    end

    before_destroy do
      FileUtils.rm_r dir if Dir.exists? dir
    end

    def self.sync
      WorkerController.instance.sync
    end

    def start!
      raise "Worker #{id} could not be started: not prepared" unless self.status == 'prepared'
      start
    end

    def start
      update(status: :queueing, moab_id: `qsub '#{self.sh}'`.strip.split(/\./).first) # Send to queue first
    end

    def cancel!
      raise "Worker #{id} could not be cancelled: not started" unless ['queueing', 'idle', 'blocked', 'active'].include? self.status
      cancel
    end

    def cancel
      `canceljob #{self.moab_id}`
      update(status: :cancelled)
    end
  end
end
