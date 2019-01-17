#!/usr/bin/env bash

#PBS -N 2
#PBS -A abc-012-ab
#PBS -q debug
#PBS -l nodes=1:ppn=1
#PBS -l walltime=5:00
#PBS -o .ripe/workers/2/job.stdout
#PBS -e .ripe/workers/2/job.stderr
#PBS -V

cd "/Users/nicolas.dejay/Dropbox/Code/ripe/spec/testpack"

(
(

# <foo.sh>

INPUT_FOO="Sample2/foo_input.txt"
FOO_MESSAGE="For You"
OUTPUT_FOO="Sample2/foo_output.txt"
LOG=".ripe/workers/2/3.log"

exec 1>"$LOG" 2>&1

# Foo is certainly one of the most important prerequisites to Bar.

echo "$(cat "$INPUT_FOO") $FOO_MESSAGE" > "$OUTPUT_FOO"

echo "##.DONE.##"

# </foo.sh>

) ; (

# <bar.sh>

INPUT_BAR="Sample2/foo_input.txt"
BAR_MESSAGE="Bar"
OUTPUT_BAR="Sample2/bar_output.txt"
LOG=".ripe/workers/2/4.log"

exec 1>"$LOG" 2>&1

# Bar is the most important consequence of Foo.

echo "$(cut -d' ' -f1 "$INPUT_BAR") $BAR_MESSAGE" > "$OUTPUT_BAR"

echo "##.DONE.##"

# </bar.sh>

)
)
