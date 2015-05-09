require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'rdoc/task'

# Default directory to look in is `/specs`
# Run with `rake spec`

RSpec::Core::RakeTask.new(:spec) do |task|
#  task.rspec_opts = ['--color', '--format', 'nested']
end

RDoc::Task.new(:rdoc         => 'rdoc',
               :clobber_rdoc => 'rdoc:clean',
               :rerdoc       => 'rdoc:force')

# task :default => :spec
