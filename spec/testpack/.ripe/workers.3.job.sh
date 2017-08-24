#!/usr/bin/env bash

#PBS -N 3
#PBS -A abc-012-ab
#PBS -q debug
#PBS -l nodes=1:ppn=1
#PBS -l walltime=5:00
#PBS -o .ripe/workers/3/job.stdout
#PBS -e .ripe/workers/3/job.stderr
#PBS -V

cd "/Users/nicolas.dejay/Dropbox/Code/ripe/spec/testpack"

(
(

# <foo.sh>

INPUT_FOO="Sample3/foo_input.txt"
FOO_MESSAGE="For You"
OUTPUT_FOO="Sample3/foo_output.txt"
LOG=".ripe/workers/3/5.log"

exec 1>"$LOG" 2>&1

# Foo is certainly one of the most important prerequisites to Bar.

echo "$(cat "$INPUT_FOO") $FOO_MESSAGE" > "$OUTPUT_FOO"

echo "##.DONE.##"

# </foo.sh>

) ; (

# <bar.sh>

INPUT_BAR="Sample3/foo_input.txt"
BAR_MESSAGE="Bar"
OUTPUT_BAR="Sample3/bar_output.txt"
LOG=".ripe/workers/3/6.log"

exec 1>"$LOG" 2>&1

# Bar is the most important consequence of Foo.

echo "$(cut -d' ' -f1 "$INPUT_BAR") $BAR_MESSAGE" > "$OUTPUT_BAR"

echo "##.DONE.##"

# </bar.sh>

)
)
