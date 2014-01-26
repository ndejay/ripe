require_relative 'block'

module Ripe
  # Forward declaration to prevent cyclic dependencies
  class Block; end

  class MultiBlock < Block
    def initialize(id, *blocks)
      super(id, blocks, {})
    end

    def topology
      [@id] + @blocks.map(&:topology)
    end
  end
end
