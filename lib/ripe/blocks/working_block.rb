module Ripe
  module Blocks
    class WorkingBlock < Block
      def initialize(filename, vars = {})
        @filename = filename
        super(File.basename(@filename), [], vars)
      end

      def topology
        [@id]
      end

      ##
      # Return working block parameters+ as a sequence of bash variable
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

      def prune(protect, depend)
        targets_exist? && !protect ? nil : self
      end

      def targets_exist?
        statuses = @vars.select { |key, _| !key[/^output_/].nil? }.values.flatten
        targets_exist = statuses.map { |target| File.exists? target }.inject(:&)

        # If there are no targets at all, then assume that all targets exist
        targets_exist == nil ? true : targets_exist
      end
    end
  end
end
