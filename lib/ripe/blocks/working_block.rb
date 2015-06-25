module Ripe

  module Blocks

    ##
    # This class represents a {Ripe::CLI::TaskCLI} that has been parametrized.
    # In the block arborescence, {WorkingBlock}s are always leaf nodes.
    #
    # @see Ripe::CLI::TaskCLI
    # @see Ripe::WorkerController::Preparer#prepare

    class WorkingBlock < Block

      ##
      # Create a new, empty {WorkingBlock}.
      #
      # @param filename [String] filename of the template file
      # @param vars [Hash<Symbol, String>] key-value pairs

      def initialize(filename, vars = {})
        @filename = filename
        super(File.basename(@filename), [], vars)
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
      # parameters to the +task+ from which the {WorkingBlock} was defined.
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

      ##
      # (see Block#prune)
      #
      # A {WorkingBlock} will be pruned if its targets exists, unless the
      # +protect+ parameter is set to +true+.

      def prune(protect, depend)
        targets_exist? && !protect ? nil : self
      end

      ##
      # (see Block#targets_exist?)
      #
      # For {WorkingBlock}s, if there is so much as a single target -- a block
      # variable starting with +output_+) that does not exist, return +false+.
      # Otherwise, return +true+.

      def targets_exist?
        statuses = @vars.select { |key, _| !key[/^output_/].nil? }.values.flatten
        targets_exist = statuses.map { |target| File.exists? target }.inject(:&)

        # If there are no targets at all, then assume that all targets exist
        targets_exist == nil ? true : targets_exist
      end

      ##
      # (see Block#topology)
      #
      # Since a {WorkingBlock} is always a leaf node in the tree, the subtree
      # starting at the leaf node only contains the {WorkingBlock}.

      def topology
        [@id]
      end

    end

  end

end
