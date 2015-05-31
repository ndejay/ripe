module Ripe

  module Blocks

    ##
    # This class represents a parallel composition of blocks, in that the
    # children blocks of an instance of this class are to be run in serial.

    class SerialBlock < MultiBlock

      ##
      # @param blocks [Array<Block>] list of children blocks

      def initialize(*blocks)
        super(:+, *blocks)
      end

      ##
      # (see Block#command)

      def command
        @blocks.map { |block| "(\n%s\n)" % block.command }.join(' ; ')
      end

      alias :super_prune :prune

      ##
      # (see MultiBlock#prune)
      #
      # A {SerialBlock} differs from a {MultiBlock} or {ParallelBlock} in that
      # there is a linear dependency for its children blocks as they are to be
      # run in serial.  If a given block must be run, then all subsequent
      # blocks that depend on it must be run as well.

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

end
