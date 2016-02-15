module Ripe
  module Blocks
    # Forward declaration to prevent cyclic dependencies
    class Block; end
  end
end

require_relative 'blocks/multi_block'
require_relative 'blocks/block'
require_relative 'blocks/parallel_block'
require_relative 'blocks/serial_block'
require_relative 'blocks/working_block'
require_relative 'blocks/bash_block'
require_relative 'blocks/liquid_block'
