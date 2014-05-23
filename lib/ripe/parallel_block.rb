require_relative 'multi_block'

module Ripe
  class ParallelBlock < MultiBlock
    def initialize(*blocks)
      super(:|, *blocks)
    end

    def command
      @blocks.map { |block| "(\n%s\n) & " % block.command }.join('') + 'wait'
    end

    def prune(protect)
      return self if protect

      @blocks = @blocks.map { |block| block.prune(protect) }.compact
      case @blocks.length
      when 0
        nil
      when 1
        @blocks.first
      else
        self
      end
    end
  end
end
