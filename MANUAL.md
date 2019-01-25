# Ripe User Manual

Ripe allows users to quickly and easily define workflows to be applied uniformly
to a set of samples.

As of 2016, it is lightweight (736 lines of code without comments and 1428 with
comments), highly modular (27 classes) and is released under the MIT license.

GitHub: https://github.com/ndejay/ripe
Gem: https://rubygems.org/gems/ripe
Issues/requests: https://github.com/ndejay/ripe/issues

The developer team:

* Nicolas De Jay
* Steven Hebert
* Genevieve Boucher

# Why Ripe?

1. Batch processing.  Process any number of samples just as easily as one.

2. Don't repeat yourself.  Avoid copy pasting code and changing file names
   for each sample.

3. Automation.  Write the glue code only once, and let ripe figure out how
   to fill in the gaps.

# Developer Guide

It is strongly recommended for users to become familiar with the basic
principles underlying ripe to reap as much as possible from it.  The following
section describes some of key principles that govern the structure and
functionality of ripe.

## Tasks and Workflows

Here, we will consider the two most fundamental building blocks of ripe: the
workflow and the task.  A **task** (i.e. c3) describes a computation applied to
an input (i.e.  alignment bam file) and that produces an output (i.e. read counts
tsv file).  In this sense, a task is analogous to a bash script, or a subroutine.
In fact, tasks are often described in ripe as bash scripts.

Often, we want to pipe tasks from one to another in a logical manner (i.e.
aligning samples and producing read counts).  In bash, the output of one task
can be provided as input to the next task using the pipe operation.  In ripe,
we can describe such sequence of tasks with a **workflow** for both serial
and parallel flows.

Let us further motivate these definitions with a more concrete example.
Suppose that we are interested in aligining samples (using STAR), counting
reads over genomic intervals and calculating mapping statistics.  We have
thus defined three tasks (i.e. star, count, stats) in a workflow
(**Figure 1**).  The tasks are run sequentially: the output of the
first task (bam) is used as input to the second task and so on.

![fig1]

If we let `+` denote the serial task joining operator, we can conveniently
describe the workflow as `STAR + c3 + stats`.

Suppose instead that we were interest not in counting reads over not one, but
multiple sets of genomic intervals.  Because counting is a relatively
inexpensive operation from the computational standpoint and each set can be
counted over independently from another, we can save processing time by
describing these counting tasks as parallel tasks in the workflow
(**Figure 2**).

![fig2]

If we let `|` denote the parallel task joining operator, we can conveniently
describe the workflow as `STAR + (c1 | c2 | c3 | c4 | c5) + stats`.

### Workflow as an Abstract Syntax Tree

If you managed not to doze off during your algorithms 101 course, you'll probably
see that this representation resembles that of an abstract syntax tree.

![fig3]

## Checkpoint Restart

One of the advantages of describing a workflow as an abstract syntax tree
that allows both serial and parallel joining of tasks is that it allows
checkpoint restarts.

### Patch mode: like a band-aid
Patch mode
```
ripe prepare -w star -o mode=patch s1
```

### Force mode
Force mode
```
ripe prepare -w star -o mode=force s1
```

### Depend mode
Depend mode
```
ripe prepare -w star -o mode=depend s1
```

## Ripe Libraries

When you write # ripe prepare –w something
it will look first in
WD: ./.ripe/workflows
Home: ~/.ripe/workflows

You can also set
export RIPELIB= (like path)

[fig1]: static/Fig1.png
[fig2]: static/Fig2.png
[fig3]: static/Fig3.png
