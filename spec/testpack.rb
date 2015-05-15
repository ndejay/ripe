module Ripe
  class TestPack
    attr_reader :path, :tasks, :workflows

    def initialize
      @path = "#{Ripe::PATH}/spec/testpack/.ripe"
      @tasks = {
        'foo' => "#{@path}/tasks/foo.sh",
        'bar' => "#{@path}/tasks/bar.sh",
      }
      @workflows = {
        'foobar' => "#{@path}/workflows/foobar.rb",
      }
    end
  end
end
