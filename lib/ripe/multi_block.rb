require_relative 'block'

module Ripe
  # Forward declaration to prevent cyclic dependencies
  class Block; end

  class MultiBlock < Block
    def initialize(id, *blocks)
      super(id, blocks, {})
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
