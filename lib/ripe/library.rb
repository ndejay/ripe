module Ripe
  class Library
    attr_reader :paths

    def initialize
      # Look for workflows and blocks in ./.ripe wherever invoked, then in
      # directories specified in the $RIPELIB environment variable.
      @paths = "#{ENV['PWD']}/.ripe:#{ENV['RIPELIB']}".split(/:/)
    end

    def find_task(handle)
      search = @paths.map do |path|
        filename = "#{path}/tasks/#{handle}.sh"
        (File.exists? filename) ? filename : nil
      end

      search.compact.first
    end

    def find_workflow(handle)
      search = @paths.map do |path|
        filename = "#{path}/workflows/#{handle}.rb"
        (File.exists? filename) ? filename : nil
      end

      search.compact.first
    end
  end
end
