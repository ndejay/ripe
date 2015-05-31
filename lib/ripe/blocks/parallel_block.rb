module Ripe

  module Blocks

    ##
    # This class represents a parallel composition of blocks, in that the
    # children blocks of an instance of this class are to be run in parallel.

    class ParallelBlock < MultiBlock

      ##
      # @param blocks [Array<Block>] list of children blocks

      def initialize(*blocks)
        super(:|, *blocks)
      end

      ##
      # (see Block#command)

      def command
        @blocks.map { |block| "(\n%s\n) & " % block.command }.join('') + 'wait'
      end

    end

  end

end
