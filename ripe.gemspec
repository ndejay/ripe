# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/ripe/version'

Gem::Specification.new do |spec|
  spec.name          = "ripe"
  spec.version       = Ripe::VERSION
  spec.authors       = ["Nicolas De Jay"]
  spec.email         = ["ndj+rubygems@pinkfilter.org"]
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
  spec.add_development_dependency "yard", "~> 0.8"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "rspec-nc", "~> 0.2"
  spec.add_development_dependency "guard-rspec", "~> 4.5"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.4"

  spec.add_runtime_dependency "activerecord", "~> 4.2"
  spec.add_runtime_dependency "fileutils", "~> 0.7"
  spec.add_runtime_dependency "liquid", "~> 3.0"
  spec.add_runtime_dependency "sqlite3", "~> 1.3"

  spec.add_runtime_dependency "ripl", "~> 0.7"
  spec.add_runtime_dependency "hirb", "~> 0.7"

  spec.add_runtime_dependency "thor", "~> 0.19"
end
