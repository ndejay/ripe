require 'liquid'

module Ripe

  module Blocks

    ##
    # This class represents a working block that should be processed using the
    # Bash adaptor block.  In +ripe+ <= 0.2.1, this templating system was the
    # default behaviour of {WorkingBlock}.
    #
    # Keys with string values in the format of:
    #
    #     vars["some_key"] = "value"
    #
    # are converted as follows:
    #
    #     SOME_KEY="value"
    #
    # Keys with array values in the format of:
    #
    #     vars["some_key"] = ["one", "two"]
    #
    # are converted as follows:
    #
    #     SOME_KEY=("one" "two")
    #
    # @see Ripe::Blocks::WorkingBlock

    class BashBlock < WorkingBlock

      ##
      # Create a new, empty {BashBlock}.
      #
      # @param filename [String] filename of the template file
      # @param vars [Hash<Symbol, String>] key-value pairs

      def initialize(filename, vars = {})
        super(filename, vars)
      end

      ##
      # Return working block +parameters+ as a sequence of bash variable
      # assignments.
      #
      # @return [String] sequence of bash variable assignments

      def declarations
        vars.map do |key, value|
          lh = key.upcase
          rh = value.is_a?(Array) ? "(\"#{value.join("\" \"")}\")" : "\"#{value}\""
          "#{lh}=#{rh}"
        end
      end

      ##
      # (see Block#command)
      #
      # The resulting string contains the result of the application of
      # parameters to the +task+ from which the {BashBlock} was defined.
      #
      # @see Ripe::DB::Task
      # @see Ripe::DSL::TaskDSL

      def command
        <<-EOF.gsub(/^[ ]+/, '')

        # <#{id}>

        #{declarations.join("\n")}

        exec 1>"$LOG" 2>&1

        #{File.new(@filename).read}
        echo "##.DONE.##"

        # </#{id}>
        EOF
      end

    end

  end

end
