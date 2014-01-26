require_relative 'multi_block'

module Ripe
  class ParallelBlock < MultiBlock
    def initialize(*blocks)
      super(:|, *blocks)
    end

    def command
      @blocks.map { |block| "(\n%s\n) & " % block.command }.join('') + 'wait'
    end
  end
end
