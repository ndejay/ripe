workflow 'foobar' do
  param :node_count,    1
  param :ppn,           1
  param :project_name,  'abc-012-ab'
  param :queue,         'debug'
  param :walltime,      '5:00'

  describe do |sample, params|
    foo = task 'foo' do
      param :input_foo,   "#{sample}/foo_input.txt"
      param :foo_message, 'For You'
      param :output_foo,  "#{sample}/foo_output.txt"
    end

    bar = task 'bar' do
      param :input_bar,   "#{sample}/foo_input.txt"
      param :bar_message, 'Bar'
      param :output_bar,  "#{sample}/bar_output.txt"
    end

    foo + bar
  end
end
