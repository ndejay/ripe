require_relative 'controller'
require_relative 'task_dsl'

module Ripe
  class WorkflowDSL
    attr_reader :handle, :vars, :callback

    def initialize(handle, &block)
      @handle = handle
      @vars = { handle: handle }
      @callback = nil

      if block_given?
        if block.arity == 1
          yield self
        else
          instance_eval &block
        end
      end
    end

    def param(key, value)
      @vars.merge!({ key => value })
    end

    def task(handle, &block)
      filename = Controller.new.library.find_task(handle)
      vars = TaskDSL.new(handle, &block).vars

      abort "Could not find task #{handle}." if filename == nil

      WorkingBlock.new(filename, vars)
    end

    def describe(&block)
      filename = Controller.new.library.find_workflow(@handle)

      abort "Could not find workflow #{@handle}." if filename == nil

      # Expect $callback to be a lambda function that takes one argument (sample)
      # and returns a Block, and $vars to be a dictionary mapping arguments to
      # values (i.e. resource allocation)

      @callback = block
    end
  end

  def workflow(handle, &block)
    $workflow = WorkflowDSL.new(handle, &block)
  end
end

