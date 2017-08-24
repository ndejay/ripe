
# <foo.sh>

INPUT_FOO="Sample3/foo_input.txt"
FOO_MESSAGE="For You"
OUTPUT_FOO="Sample3/foo_output.txt"
LOG=".ripe/workers/3/7.log"

exec 1>"$LOG" 2>&1

# Foo is certainly one of the most important prerequisites to Bar.

echo "$(cat "$INPUT_FOO") $FOO_MESSAGE" > "$OUTPUT_FOO"

echo "##.DONE.##"

# </foo.sh>
