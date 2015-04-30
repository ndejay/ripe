if !ENV['CODECLIMATE_REPO_TOKEN'].nil?
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require_relative '../lib/ripe'
