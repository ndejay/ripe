require_relative 'multi_block'

module Ripe
  class SerialBlock < MultiBlock
    def initialize(*blocks)
      super(:+, *blocks)
    end

    def command
      @blocks.map { |block| "(\n%s\n)" % block.command }.join(' ; ')
    end

    alias :super_prune :prune

    def prune(protect, depend)
      return super_prune(protect, depend) if !depend
      return self if protect

      @blocks = @blocks.map do |block|
        new_protect = !block.targets_exist?
        new_block = block.prune(protect, depend)
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
