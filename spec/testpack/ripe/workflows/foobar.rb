workflow 'foobar' do
  param :node_count,    1
  param :ppn,           8
  param :project_name,  'abc-012-ab'
  param :queue,         'queue'
  param :walltime,      '12:00:00'

  describe do |sample, params|
    foo = task 'foo' do
      param :input_foo,   "#{sample}/input_foo"
      param :foo_message, 'FOO'
      param :output_foo,  "#{sample}/output_foo"
    end

    bar = task 'bar' do
      param :input_bar,   "#{sample}/input_bar"
      param :bar_message, 'BAR'
      param :output_bar,  "#{sample}/output_bar"
    end

    foo + bar
  end
end
