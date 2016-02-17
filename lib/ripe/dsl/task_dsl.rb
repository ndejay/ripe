module Ripe

  module DSL

    ##
    # Create a +WorkingBlock+ using a DSL.  It is syntactic sugar for
    #
    #    foo = WorkingBlock.new('/path/to/foo', {
    #      param1: 'val1',
    #      param2: 'val2',
    #    })
    #
    # in the form of:
    #
    #    foo = task 'foo' do
    #      param :param1, 'val1'
    #      param :param2, 'val2'
    #    end
    #
    #    foo = task 'foo' do |t|
    #      t.param :param1, 'val1'
    #      t.param :param2, 'val2'
    #    end
    #
    #    foo = task 'foo', task: 'bash' do |t|
    #      t.param :param1, 'val1'
    #    end
    #
    # It internally uses +Ripe::DSL::TaskDSL+ to provide the DSL.
    #
    # @see Ripe::DSL::TaskDSL
    # @see Ripe::DSL::WorkflowDSL
    # @see Ripe::DSL::task
    #
    # @param handle [String] the name of the task
    # @param block [Proc] executes block in the context of +TaskDSL+
    # @return [WorkingBlock, nil]

    def task(handle, vars = {type: 'bash'}, &block)
      # Obtain list of `WorkingBlock` types.
      working_block = Blocks::WorkingBlock.subclasses.select { |k| k.id == vars[:type] }.first

      filename = "#{handle}.#{working_block.extension}"
      full_filename = Library.find(:task, filename)

      if full_filename == nil
        abort "Could not find task `#{filename}`."
      # else
      #   puts "Found task `#{handle}` @ `#{full_filename}`."
      end

      params = TaskDSL.new(handle, &block).params
      working_block.new(full_filename, params)
    end

    ##
    # This class provides a DSL for defining a task.  It should only be called
    # by #task.
    #
    # @attr_reader params [Hash<Symbol, String>] list of parameters

    class TaskDSL

      attr_reader :params

      ##
      # Create a new +Task+ DSL
      #
      # @param handle [String] the name of the task
      # @param block [Proc] executes block in the context of +TaskDSL+

      def initialize(handle, &block)
        @handle = handle
        @params = {}

        if block_given?
          if block.arity == 1
            yield self
          else
            instance_eval &block
          end
        end
      end

      ##
      # Register a parameter
      #
      # @param key [Symbol] the parameter name
      # @param value [String] its value

      def param(key, value)
        @params.merge!({ key => value })
      end

    end

  end

end
