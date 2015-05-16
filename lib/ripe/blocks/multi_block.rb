module Ripe
  module Blocks
    class MultiBlock < Block
      def initialize(id, *blocks)
        # Ignore nil objects
        super(id, blocks.compact, {})
      end

      def prune(protect, depend)
        return self if protect

        @blocks = @blocks.map { |block| block.prune(protect, depend) }.compact
        case @blocks.length
        when 0
          nil
        when 1
          @blocks.first
        else
          self
        end
      end

      def topology
        [@id] + @blocks.map(&:topology)
      end

      def targets_exist?
        @blocks.map(&:targets_exist?).inject(:&)
      end
    end
  end
end
