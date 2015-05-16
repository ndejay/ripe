require 'fileutils'

module Ripe
  module DB
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
    end
  end
end
