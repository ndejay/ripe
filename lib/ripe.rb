require_relative 'ripe/controller'

module Ripe
  PATH = File.expand_path('..', File.dirname(__FILE__))

  # Compute version by concatenating latest tag and latest commit hash
  VERSION = `(cd #{PATH};
    echo $(git describe --abbrev=0 --tags).$(git rev-parse --short HEAD))`
end
