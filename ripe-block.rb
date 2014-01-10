require 'ripe-parallel_block'
require 'ripe-serial_block'

class Block
  attr_reader :id, :blocks
  attr_accessor :vars

  def initialize(id, blocks = [], vars = {})
    @id, @blocks, @vars = id, blocks, vars
  end

  def |(block)
    ParallelBlock.new(self, block)
  end

  def +(block)
    SerialBlock.new(self, block)
  end
end
