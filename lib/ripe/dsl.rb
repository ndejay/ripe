module Ripe

  # This module contains `domain-specific language` syntactic sugar for
  # defining workflows and tasks.

  module DSL; end

end

require_relative 'dsl/task_dsl'
require_relative 'dsl/workflow_dsl'
