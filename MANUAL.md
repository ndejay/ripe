# Ripe

[GitHub](https://github.com/ndejay/ripe) | [Gem](https://rubygems.org/gems/ripe) | [Issues](https://github.com/ndejay/ripe/issues)

Ripe allows users to quickly and easily define workflows to be applied uniformly
to a set of samples.  As of 2016, it is lightweight (736 lines of code without
comments and 1428 with comments), highly modular (27 classes) and is released
under the MIT license.

## Why Ripe?

1. Batch processing.  Process any number of samples just as easily as one.

2. Don't repeat yourself.  Avoid copy pasting code and changing file names
   for each sample.

3. Automation.  Write the glue code only once, and let ripe figure out how
   to fill in the gaps.

## The Team

Ripe is currently being developed by a [team](https://github.com/ndejay/raptor/graphs/contributors)
from the [Kleinman Lab](https://github.com/ndejay/raptor/graphs/contributors):

* [Nicolas De Jay](https://github.com/ndejay)
* [Geneviève Boucher](https://github.com/genevievebo)
* [Steven Hébert](https://github.com/HebertS)

# Getting Started

* Organize test data set
* Define test task/workflow
* Run ripe
* ???
* Profit

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
Suppose that we are interested in aligning samples (using STAR), counting
reads over genomic intervals and calculating mapping statistics.  We have
thus defined three tasks (i.e. star, count, stats) in a workflow
(**Figure 1**).  The tasks are run sequentially: the output of the
first task (bam) is used as input to the second task and so on.

![fig1]

If we let `+` denote the serial task joining operator, we can conveniently
describe the workflow as `STAR + c3 + stats`.

Suppose instead that we were interested in counting reads over not one, but
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

Under the `patch` mode, only tasks with missing output files are run.  This is the
default mode of operation for ripe.

```
ripe prepare -w star -o mode=patch s1
```

![fig4]

### Force mode

Under the `force` mode, all tasks are run regardless of whether output files are
missing or not.

```
ripe prepare -w star -o mode=force s1
```

![fig5]

### Depend mode

Under the `depend` mode, tasks with missing output files are run, as well as
any tasks downstream even if their respective output files are not missing.  This
is for the case where a critical parameter change has been made that will affect
subsequent steps, but many upstream or parallel tasks remain unaffected.

```
ripe prepare -w star -o mode=depend s1
```

![fig6]

## Ripe Libraries

When you write # ripe prepare –w something
it will look first in
WD: ./.ripe/workflows
Home: ~/.ripe/workflows

You can also set
export RIPELIB= (like path)

# F.A.Q.

## Why Ruby?

Ruby is a programming language developed in 1995 by Yukihiro "Matz" Matsumoto
that combines pure object-oriented programming with many elements of
functional programming.  The language focuses on elegance, brevity and
simplicity.  A decade later, in 2004, David Heinemeier Hansson published the
first version of Ruby On Rails, a highly influencial server-side web
application framework.  Rails emphasizes design patterns such as convention
over configuration, don't repeat yourself, active record pattern in addition
to the model-view-controller paradigm.

Features that are particularly useful for batch processing:

* Domain-specific language (DSL).  Highly flexible syntax that allows code
  to almost be read like language.

* Templating.  Embedded Ruby (ERB), Liquid Templating.

* Object-relational mapping (ORM).  Never write an SQL statement again.

We wanted to make use of these features so that is why we went with Ruby and Rails.

[fig1]: static/Fig1.png
[fig2]: static/Fig2.png
[fig3]: static/Fig3.png
[fig4]: static/Fig4.png
[fig5]: static/Fig5.png
[fig6]: static/Fig6.png
