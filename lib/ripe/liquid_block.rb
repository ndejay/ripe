require 'liquid'
require_relative 'filter'

module Ripe
  class LiquidBlock < Block
    def initialize(filename, vars = {})
      @filename = filename
      super(File.basename(@filename), [], vars)
    end

    def topology
      [@id]
    end

    def command
      vars = @vars.inject({}) { |memo, (k, v)| memo[k.to_s] = v; memo }

      template = Liquid::Template.parse(File.new("#{@filename}").read)
      template.render(vars)
    end
  end
end
