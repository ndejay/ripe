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
  foo = Task('foo', {
    input_foo:   "#{sample}/input_foo",
    foo_message: 'FOO',
    output_foo:  "#{sample}/output_foo",
  })
  bar = Task('bar', {
    input_bar:   "#{sample}/input_bar",
    bar_message: 'BAR',
    output_bar:  "#{sample}/output_bar",
  })
  foo + bar
end
