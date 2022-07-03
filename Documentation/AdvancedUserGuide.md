# Clues for Clue: An Advanced User Guide

This guide aims to equip users fundamental knowledge required to reliably operate, and if needed, troubleshoot
Clue, the Swift library and command-line utility. Achieving so is less about "holding it right", rather, it
should feels like "oh, Clue is but these simple steps, scripted."

## Introduction

Clue was to solve one problem: finding symbol references in Swift. A symbol can be things like a function,
a protocol, a property, etc. Often, a Swift project defines a symbol in one target (or "module"), and
references it in many other targets. In large projects, it could be challenging to track down these references
by name: there maybe other symbols with same or partially same names, you may have other non-Swift text
files containing the name, etc.

Xcode provides some solutions. One can search by symbol reference in the Find navigator, or use one of the
built in functions to find callers, extensions, subclasses, etc. Clue leverages the same underlying
infrastructure with Xcode (thanks, Apple!), therefore, it can achieve the same functionalities. However, we
don't intend to simply replace Xcode. Clue, by being a library, and command-line tool, enables programmable
actions on the search result; by giving transparency to its inner-working, Clue removes the fog that empowers
its users to find out why some search doesn't work as intended, and address it.

So, what's Clue good for? Here's some ideas:

* Track migration/deprecation/adoption progress of certain symbols in large projects.
* In command-line, pipe Clue's search results to scripts to perform some follow-up actions.
* Build general purpose refactor tools with finding the symbols being its first step.
* Help you self navigate complex projects.

## Technical Overview Of the "find" Subcommand

This is the most important portion of this guide: we'll discuss how Clue works behind the scenes. Clue
deliberately exposes all of its mechanism so that users always have ways to intervene when unexpected things
happen.

On a high level, Clue facilitates a series of steps that leads to a successful query into [LLVM's index
store][].

1. Initialize the index store database. This involves two user inputs: location of the libIndexStore dynamic
   library, and location of the index store built from user's project.
2. Locate a definition of a symbol according to user's input.
3. Leveraging IndexStoreDB, find all the references of the symbol, optionally, filter them by some criteria
   the user provides before returning them as the final output.

Each step produces a deterministic output as the next's input. As the user, you can directly provide such
inputs for all steps. This setup yields full control to you: if Clue could not complete a step, you can always
skip it by providing the answer. Of course, Clue will do its best to help you figure it out when this happens.

Now, let's dive into more details.

### Step 1: Initializing the index store

Swift produces an _index_ database as part of the compilation process. Both Xcode and Clue uses it to find
symbol references. Our first order of business is to find it for your project.

As a Clue user, you are responsible for the "step 0": making sure the index for your project exists. For Xcode
and SwiftPM projects, this usually just means a full debug build for _all relevant targets_. For less common
build systems such as CMake and Bazel, as a old Linux manual might say: "contact your system admin".

A few more words on "relevancy". A good build system is lazy: if both module A, and B depends on C, building
C usually means skipping A and B; similarly, although building B requires building C as well, it's not
necessary to build A. In this example, if you want to find references of a definition from C in both A *and*
B, both will have to be built separately. A symbol's definitional module and consumer modules are 1-to-many.
If Clue (or Xcode, for that matter) didn't find the reference you are looking for, chances are you didn't
build its module.

Back to Step 1.

Step 1 requires two pieces of information. The more important between them is the location of your index.
Chances are, you don't know where Swift puts the index store when you build your project with Xcode or
SwiftPM. In that case, you can tell Clue one of:

* the name of your Xcode project, if you build with Xcode
* the path to your SwiftPM project, if you build with SwiftPM

Clue would assume the index store is at a location chosen by Xcode or SwiftPM by default in this case.

When you customize the index's location, you may also tell Clue the full path to it. You can also try this
option if, for some reason, Clue couldn't infer the index store from your Xcode project name or SwiftPM
project path.

For completeness's sake, Clue also needs the location of a dynamic library "libIndexStore". Most of the time
it's sufficient to let it figure out this information. Just know that you can specify it explicitly, as well.

When you specify both paths explicitly, you are effectively bypassing Step 1.

If everything in step 0 and 1 are done correctly, Clue will have access to the index of your project, and
prepare for Step 2.

[LLVM's index store]: https://github.com/apple/llvm-project/tree/apple/main/clang/tools/IndexStore

### Step 2: What are you looking for?

When we think of a reference to _something_, it's usally a string that appears in the source code, such as
"AwesomeViewController" or "someVariable". In Step 2, the goal is to map this string in our head to
a actual location in our project where the symbol is defined.

Sometimes our symbol name is unique, and "AwesomeViewController" is really, obviously, in
`AwesomeTarget/Sources/AwesomeViewController.swift`, line `2`, column `6`. In large projects, things aren't so
straight forward.

For example, there might be an "AwesomeViewControllerDelegate", or, worse, a second "AwesomeViewController" in
a different module. There might be more than one "someVariable", each live in a different namespace.

Instead of this possibly ambiguous string, Clue aims to map it to a "Unified Symbol Resolution", or USR. Think
of a USR as the URL to a symbol: it's unique and unambiguous. Finding a symbol's USR is the end goal of Step
2.

When Clue finds more than one USRs for your symbol name, Step 2 has failed. Here, you can supply more
information to refine the search. For example, the module the symbol is defined, or what kind of definition it
is (e.g "variable", "enum", "typealias", etc). If the Clue finds more USRs with partially matched names like
"AwesomeViewControllerDelegate", in addition to "AwesomeViewController", you can tell Clue to use a stricter
match to filter it out. This option is not default on, because a strict name for functions include their
parameter names and parenthesis (e.g. `update(name:age:inventory:)`), which may be tricky to get right for the
unfamiliar.

If none of the criteria successfully results in a single USR, you can specify the USR directly. Note, Clue
always returns the list of USRs in case of ambiguous symbols. When you specify the USR, you are effectively
bypassing step 2.

A special note: some definitions are referred to in a very specific way. A getter for a variable `xyz` is
`getter:xyz`; a setter is `setter:xyz`. Other examples are `willSet:xyz`, and `didSet:xyz`.

With an USR at hand, Clue will move on to find its references in Step 3.

### Step 3: Too many results?

At this stage, Clue will find __all__ the references available in your index store. Sometimes this is not
a good thing: maybe you care more about the subclass to a `class` rather than its instantiations; or maybe you
want to find where a variable's value gets written to, but not read from. Step 3 is all about filtering the
references by their roles so that you get the exact set in the output. This is extremely important if you plan
to consume Clue's output with follow-up actions such as code refactoring.

Each reference has one or more "roles" associated with it. The exact details of what roles are assigned to
what reference are very complex. In practice, however, it's sufficient to observe the roles of symbols in the
initial result, find the roles uniquely associated with the unwanted items, and tell Clue to exclude them in
the next run.

Now, an example.

Often, projects refer to protocols for to different purposes: some types conform to it, and some variables use
it as their type (existentials). Using the protocol's USR, we'll get both type of references by default. By
inspecting the result, we found that the protocol conformances has a role `baseOf`, and the existentials don't
have it. So, we will tell Clue to _exclude_ the role `baseOf`, in order to get all the existential references.

There are a huge combination of roles for different type of symbol references. They are assigned by the
developers of index store and Swift. In practice, we find it unnecessary to learn it all. To improve user
experiences, Clue provides some "preset" roles for the command-line users. For our example above, one can use
the flag `--role-instance-only` to accomplish the same thing.

Clue takes a inclusive list of roles, and a list of roles to exclude. Both are optional. By default, all roles
are included, and none excluded.

Congratulations, you've found all the symbol references from your project, no less, no more!
