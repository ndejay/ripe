require_relative 'controller'
require_relative 'working_block'

module Ripe
  class TaskDSL
    attr_reader :vars

    def initialize(handle, &block)
      @handle = handle
      @vars = {}

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
  end
end

def task(handle, &block)
  filename = Controller.new.library.find_task(handle)
  vars = TaskDSL.new(handle, &block).vars

  abort "Could not find task #{handle}." if filename == nil

  WorkingBlock.new(filename, vars)
end
