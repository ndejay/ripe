
# <foo.sh.erb>

exec 1>".ripe/workers/2/6.log" 2>&1

# Foo is certainly one of the most important prerequisites to Bar.

echo "$(cat "Sample2/foo_input.txt") For You" > "Sample2/foo_erb_output.txt"

echo "##.DONE.##"

# </foo.sh.erb>
