require_relative 'controller'

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
