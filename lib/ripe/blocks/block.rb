module Ripe

  module Blocks

    ##
    # This class represents the fundamental building block of ripe.
    #
    # @abstract
    #
    # @attr_reader id [String] a mandatory, but optionally unique identifier
    #   for the block
    # @attr_reader blocks [Array<Block>] list of children blocks
    # @attr vars [Hash<Symbol, String>] key-value pairs
    #
    # @see Ripe::WorkerController::Preparer

    class Block

      attr_reader :id, :blocks

      attr_accessor :vars

      ##
      # @param id [String] a mandatory, but optionally unique identifier
      #   for the block
      # @param blocks [Array<Block>] list of children blocks
      # @param vars [Hash<Symbol, String>] key-value pairs

      def initialize(id, blocks = [], vars = {})
        @id, @blocks, @vars = id, blocks, vars
      end

      ##
      # Return the string command of the subtree starting at the current block.
      #
      # @return [String] subtree command

      def command
        ''
      end

      ##
      # Prune the subtree starting at the current block.
      #
      # @param protect [Boolean] if the current block (and recursively, its
      #   children) should be protected from pruning -- setting this parameter
      #   to +true+ guarantees that the block will not be pruned
      # @param depend [Boolean] if the current block is unprotected because
      #   its parent (serially) needs to be executed
      # @return [Block, nil] a +Block+ representing the subtree that has not
      #   been pruned, and +nil+ otherwise

      def prune(protect, depend)
        self
      end

      ##
      # Test whether all targets for the current block exist.
      #
      # @return [Boolean] whether all targets exist

      def targets_exist?
        # {Block} is an abstract class.  By default, assume that no targets
        # exist.
        false
      end

      ##
      # Return the topology of the subtree starting at the current block in a
      # nested list format.  The first element of any nested list is the
      # identifier of the corresponding block in the subtree, and the
      # subsequent elements are each a subtree corresponding to the children
      # blocks of the current subtree.
      #
      # @return [Array<Symbol, Array>] topology nested list

      def topology
        []
      end

      ##
      # Compose a new parallel block from two blocks.  This method provides
      # syntactic sugar in the form:
      #
      #   Block1 | Block2 | Block3
      #
      # @param block [Block] a block
      # @return [Block] parallel block composition of the current block with
      #   the block passed in the argument list

      def |(block)
        ParallelBlock.new(self, block)
      end

      ##
      # Compose a new serial block from two blocks.  This method provides
      # syntactic sugar in the form:
      #
      #   Block1 + Block2 + Block3
      #
      # @param (see #|)
      # @return [Block] serial block composition of the current block with
      #   the block passed in the argument list

      def +(block)
        SerialBlock.new(self, block)
      end

    end

  end

end

##
# +NilClass+ is monkey-patched+ to provide syntactic sugar for +Block#|+ and
# +Block#\++ by treating +nil+ like an empty block.
#
# @see Ripe::Blocks::Block

class NilClass

  ##
  # If attempting to compose a new block with a +nil+ element, ignore the +nil+
  # element.
  #
  # @param (see Ripe::Blocks::Block#|)
  # @return [Block] the +block+ parameter

  def |(block)
    raise NoMethodError unless Ripe::Blocks::Block > block.class
    block
  end

  ##
  # (see #|)

  def +(block)
    self.|(block)
  end

end
