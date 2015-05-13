$vars = {
  group_num:     1,
  handle:        'foobar',
  node_count:    1,
  ppn:           8,
  project_name:  'abc-012-ab',
  queue:         'queue',
  walltime:      '12:00:00',
}

$callback = lambda do |sample, vars|

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
