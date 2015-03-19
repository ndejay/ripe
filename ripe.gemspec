# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ripe/version'

Gem::Specification.new do |spec|
  spec.name          = "ripe"
  spec.version       = Ripe::VERSION
  spec.authors       = ["Nicolas De Jay"]
  spec.email         = ["ndj@pinkfilter.org"]
  spec.summary       = %q{Abstraction layer between the MOAB/Torque stack and your pipeline.}
  # spec.description   = %q{Write a longer description. Optional.}
  spec.homepage      = "https://github.com/ndejay/ripe"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "fileutils"
  spec.add_development_dependency "liquid"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "hirb"
  spec.add_development_dependency "irbtools"
  spec.add_development_dependency "thor"
  spec.add_development_dependency "wirb"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-nc"
end
