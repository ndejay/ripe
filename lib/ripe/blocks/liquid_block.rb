require 'liquid'

module Ripe

  module Blocks

    ##
    # This class represents a working block that should be processed using the
    # Liquid templating engine, rather than the simple +bash+ engine defined in
    # {WorkingBlock}.
    #
    # @see Ripe::Blocks::WorkingBlock

    class LiquidBlock < WorkingBlock

      ##
      # Create a new, empty {LiquidBlock}.
      #
      # @param filename [String] filename of the template file
      # @param vars [Hash<Symbol, String>] key-value pairs

      def initialize(filename, vars = {})
        super(filename, vars)
      end

      ##
      # Return liquid block +parameters+ as a +Hash<Symbol, Object>+.
      #
      # @return [Hash<Symbol, Object>] liquid block +parameters+

      def declarations
        @vars.inject({}) { |memo, (k, v)| memo[k.to_s] = v; memo }
      end

      ##
      # (see Block#command)
      #
      # The resulting string contains the render result of the liquid template
      # based on the parameters specified in +vars+.

      def command
        template = Liquid::Template.parse(File.new(@filename).read)
        template.render(declarations)
      end

    end

  end

end
