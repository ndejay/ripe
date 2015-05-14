require 'active_record'
require 'fileutils'
require_relative 'task'
require_relative 'worker_controller'

module Ripe
  class Worker < ActiveRecord::Base
    has_many :tasks, dependent: :destroy

    def dir
      "#{Repo::REPOSITORY_PATH}/workers/#{self.id}"
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

    def start
      raise "Worker #{id} could not be started: not prepared" unless self.status == 'prepared'
      WorkerController.instance.start(self)
    end

    def cancel
      raise "Worker #{id} could not be cancelled: not started" unless ['queueing', 'idle', 'blocked', 'active'].include? self.status
      WorkerController.instance.cancel(self)
    end
  end
end
