require_relative 'multi_block'

class SerialBlock < MultiBlock
  def initialize(*blocks)
    super(:+, *blocks)
  end

  def command
    @blocks.map { |block| "(\n%s\n)" % block.command }.join(' ; ')
  end
end
