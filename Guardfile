guard :rspec, cmd: 'rspec' do
  watch(%r{^spec/.+\.rb$}) { 'spec' }
  watch(%r{^lib/ripe/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
end
