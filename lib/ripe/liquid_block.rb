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

    def prune(protect)
      targets_exist? && !protect ? nil : self
    end

    def targets_exist?
      statuses = @vars.select { |key, _| !key[/^output_/].nil? }.values.flatten
      statuses.map { |target| File.exists? target }.inject(:&)
    end
  end
end
