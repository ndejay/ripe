module Ripe

  module DSL

    ##
    # Create a +Workflow+ using a DSL.  It is syntactic sugar for
    #
    #    workflow 'foobar' do
    #      param :node_count,    1
    #      param :ppn,           8
    #      param :project_name,  'abc-012-ab'
    #      param :queue,         'queue'
    #      param :walltime,      '12:00:00'
    #
    #      describe do |sample, params|
    #        # task
    #      end
    #    end
    #
    # The block given in +describe+ has two mandatory arguments:
    #   - sample: the name of the sample
    #   - params: the parameters defined at the workflow-level
    #
    # It internally uses +Ripe::DSL::WorkflowDSL+ to provide the DSL.
    #
    # @see Ripe::DSL::TaskDSL
    # @see Ripe::DSL::WorkflowDSL
    # @see Ripe::DSL::task
    #
    # @param handle [String] the name of the workflow
    # @param block [Proc] executes block in the context of +WorkflowDSL+

    def workflow(handle, &block)
      $workflow = WorkflowDSL.new(handle, &block)
    end

    ##
    # This class provides a DSL for defining a workflow.  It should only be
    # called by #workflow.

    class WorkflowDSL

      attr_reader :handle, :params, :callback

      ##
      # Create a new +Workflow+ DSL
      #
      # @param handle [String] the name of the workflow
      # @param block [Proc] executes block in the context of +WorkflowDSL+

      def initialize(handle, &block)
        @handle = handle
        @params = { handle: handle }
        @callback = nil

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

      ##
      # Describe the workflow in terms of a task.
      #
      # @param block [Proc] a callback function that has arguments the name of
      #   sample and a hash of parameters provided by the workflow and by the
      #   command line.

      def describe(&block)
        @callback = block
      end

    end

  end

end
