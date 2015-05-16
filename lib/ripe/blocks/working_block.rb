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

      def command
        declarations = vars.map do |key, value|
          lh = key.upcase
          rh = value.is_a?(Array) ? "(\"#{value.join("\" \"")}\")" :
            "\"#{value}\""
          "#{lh}=#{rh}"
        end

        "\n# <#{id}>" +
          ("\n" * 2) + declarations.join("\n") +
          ("\n" * 2) + "exec 1>\"$LOG\" 2>&1" +
          ("\n" * 2) + File.new(@filename).read + "\necho \"##.DONE.##\"" +
          ("\n" * 2) + "# </#{id}>\n"
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
