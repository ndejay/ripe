require_relative 'parallel_block'
require_relative 'serial_block'

module Ripe
  class Block
    attr_reader :id, :blocks
    attr_accessor :vars

    def initialize(id, blocks = [], vars = {})
      @id, @blocks, @vars = id, blocks, vars
    end

    def prune(protect)
      self
    end

    def |(block)
      ParallelBlock.new(self, block)
    end

    def +(block)
      SerialBlock.new(self, block)
    end
  end
end
