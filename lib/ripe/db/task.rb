module Ripe
  module DB
    class Task < ActiveRecord::Base
      belongs_to :worker

      def dir
        "#{self.worker.dir}"
      end

      def log
        "#{self.dir}/#{self.id}.log"
      end

      def sh
        "#{self.dir}/#{self.id}.sh"
      end
    end
  end
end
