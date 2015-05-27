module Ripe

  class CLI

    ##
    # This class defines helper methods for +Ripe::CLI+.
    #
    # @see Ripe::CLI

    class Helper

      ##
      # Parses a string representing a hash in the format of +a=1,b=2,c=3+ into a
      # hash in the format of +{a: 1, b: 2, c: 3}+.
      #
      # @param options [String] a hash in the format of +a=1,b=2,c=3+
      # @return [Hash] a hash in the format of +{a: 1, b: 2, c: 3}+

      def self.parse_cli_opts(options)
        params = options.split(/,/).map do |pair|
          key, value = pair.split(/=/)
          { key.to_sym => value }
        end
        params.inject(&:merge) || {}
      end

    end

  end

end
