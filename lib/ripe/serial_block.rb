require_relative 'multi_block'

module Ripe
  class SerialBlock < MultiBlock
    def initialize(*blocks)
      super(:+, *blocks)
    end

    def command
      @blocks.map { |block| "(\n%s\n)" % block.command }.join(' ; ')
    end

    def prune(protect)
      return self if protect

      @blocks = @blocks.map do |block|
        new_protect = true if !block.targets_exist?
        new_block = block.prune(protect)
        protect = new_protect
        new_block
      end
      @blocks = @blocks.compact

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
