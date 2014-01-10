require 'liquid'

module Filter
  def jargs(args)
    args.join('" "')
  end
  
  def cargs(args)
    args.join('", "')
  end
  
  def default(variable, value)
    variable || value
  end
  
  def index(args, index)
    args[index]
  end
end

Liquid::Template.register_filter(Filter)
