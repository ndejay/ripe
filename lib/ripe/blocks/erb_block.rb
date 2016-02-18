require 'erb'

module Ripe

  module Blocks

    ##
    # This class represents a working block that should be processed using the
    # ERB templating system.
    #
    # Keys defined as:
    #
    #     vars["some_key"] = "value"
    #
    # can be substituted in the ERB template using:
    #
    #     <%= vars.some_key %>
    #
    # @see Ripe::Blocks::ERBBlock

    class ERBBlock < WorkingBlock
      #
      ##
      # Create a new, empty {LiquidBlock}.
      #
      # @param filename [String] filename of the template file
      # @param vars [Hash<Symbol, String>] key-value pairs

      def initialize(filename, vars = {})
        super(filename, vars)
      end

      ##
      # (see Block#command)
      #
      # The resulting string contains the render result of the liquid template
      # based on the parameters specified in +vars+.

      def command
        vars = @vars
        vars.define_singleton_method(:get_binding) { binding } # Expose private method
        vars.define_singleton_method(:method_missing) do |name|
          return self[name] if key? name
          self.each { |k,v| return v if k.to_s.to_sym == name }
          # super.method_missing name
        end

        template = <<-EOF.gsub(/^[ ]+/, '')

        # <#{id}>

        exec 1>"<%= vars.log %>" 2>&1

        #{File.new(@filename).read}
        echo "##.DONE.##"

        # </#{id}>
        EOF

        ERB.new(template).result(vars.get_binding)
      end

      ##
      # Return string handle for referring to this type of `WorkingBlock`.
      #
      # @see Ripe::DSL::TaskDSL
      #
      # @return [String]

      def self.id
        'erb'
      end

      ##
      # Return expected file extension type for this type of `WorkingBlock`.
      #
      # @see Ripe::DSL::TaskDSL
      #
      # @return [String]

      def self.extension
        'sh.erb'
      end

    end

  end

end
