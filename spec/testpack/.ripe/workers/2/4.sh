
# <foo.sh>

INPUT_FOO="Sample2/foo_input.txt"
FOO_MESSAGE="For You"
OUTPUT_FOO="Sample2/foo_output.txt"
LOG=".ripe/workers/2/4.log"

exec 1>"$LOG" 2>&1

# Foo is certainly one of the most important prerequisites to Bar.

echo "$(cat "$INPUT_FOO") $FOO_MESSAGE" > "$OUTPUT_FOO"

echo "##.DONE.##"

# </foo.sh>
