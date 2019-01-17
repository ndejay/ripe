require_relative 'ripe/blocks'
require_relative 'ripe/dsl'
require_relative 'ripe/library'
require_relative 'ripe/worker_controller'

require_relative 'ripe/cli'
require_relative 'ripe/version'

module Ripe
  PATH = File.expand_path('..', File.dirname(__FILE__))
  REPOSITORY_PATH = '.ripe'
end
