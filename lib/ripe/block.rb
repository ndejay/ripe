require_relative 'parallel_block'
require_relative 'serial_block'

module Ripe
  class Block
    attr_reader :id, :blocks
    attr_accessor :vars

    def initialize(id, blocks = [], vars = {})
      @id, @blocks, @vars = id, blocks, vars
    end

    def prune(protect, depend)
      self
    end

    # Syntactic sugar of the form: Block1 | Block2 | Block3
    def |(block)
      ParallelBlock.new(self, block)
    end

    # Syntactic sugar of the form: Block1 + Block2 + Block3
    def +(block)
      SerialBlock.new(self, block)
    end
  end
end

class NilClass
  # Syntactic sugar of the form: nil | Block1
  def |(block)
    raise NoMethodError unless Block > block.class
    block
  end

  # Syntactic sugar of the form: nil + Block1
  def +(block)
    raise NoMethodError unless Block > block.class
    block
  end
end
