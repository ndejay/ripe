module Ripe

  module Blocks

    ##
    # This class represents a block composition, that is, a placeholder block
    # that joins multiple blocks together.
    #
    # This class only exists to provide a superclass for {ParallelBlock} and
    # {SerialBlock}.
    #
    # @abstract
    #
    # @see Ripe::Blocks::ParallelBlock
    # @see Ripe::Blocks::SerialBlock

    class MultiBlock < Block

      ##
      # @param id [String] a mandatory, but optionally unique identifier
      #   for the block
      # @param blocks [Array<Block>] list of children blocks

      def initialize(id, *blocks)
        # Ignore nil objects
        super(id, blocks.compact, {})
      end

      ##
      # (see Block#prune)
      #
      # Unless the block is protected, attempt to prune all children blocks.
      # If all blocks are pruned, return nothing.  If a single block remains,
      # return that block.  If more than one block remains, return the current
      # {MultiBlock}.

      def prune(protect, depend)
        if !protect
          @blocks = @blocks.map { |block| block.prune(protect, depend) }.compact
          case @blocks.length
          when 0; nil
          when 1; @blocks.first
          else;   self
          end
        else
          self
        end
      end

      ##
      # (see Block#targets_exist?)
      #
      # A {MultiBlock}'s targets exist if the targets of all its # children
      # exist.

      def targets_exist?
        @blocks.map(&:targets_exist?).inject(:&)
      end

      ##
      # (see Block#topology)

      def topology
        [@id] + @blocks.map(&:topology)
      end

    end

  end

end
