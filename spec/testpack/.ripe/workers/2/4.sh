
# <bar.sh>

INPUT_BAR="Sample2/foo_input.txt"
BAR_MESSAGE="Bar"
OUTPUT_BAR="Sample2/bar_output.txt"

exec 1>"$LOG" 2>&1

# Bar is the most important consequence of Foo.

echo "$(cut -d' ' -f1 "$INPUT_BAR") $BAR_MESSAGE" > "$OUTPUT_BAR"

echo "##.DONE.##"

# </bar.sh>
