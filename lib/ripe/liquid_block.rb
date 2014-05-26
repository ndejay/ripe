require 'liquid'
require_relative 'working_block'

module Ripe
  class LiquidBlock < WorkingBlock
    def initialize(filename, vars = {})
      super(filename, vars)
    end

    def command
      vars = @vars.inject({}) { |memo, (k, v)| memo[k.to_s] = v; memo }

      template = Liquid::Template.parse(File.new(@filename).read)
      template.render(vars)
    end
  end
end
