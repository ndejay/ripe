module Ripe
  class TestPack
    attr_reader :path, :lib_path, :tasks, :workflows, :samples, :steps

    def initialize
      @path = "#{PATH}/spec/testpack"
      @lib_path = "#{@path}/#{REPOSITORY_PATH}"
      @tasks = {
        'foo' => "#{@lib_path}/tasks/foo.sh",
        'bar' => "#{@lib_path}/tasks/bar.sh",
        'foo_erb' => "#{@lib_path}/tasks/foo_erb.sh"
      }
      @workflows = {
        'foobar' => "#{@lib_path}/workflows/foobar.rb",
      }
      @samples = [
        'Sample1',
        'Sample2',
        'Sample3'
      ]
      @steps = [
        'foo_input.txt',
        'foo_output.txt',
        'bar_output.txt',
        'foo_erb_output.txt'
      ]
    end
  end
end
