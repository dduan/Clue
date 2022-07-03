# Clue: Getting Started

## Installation

- Download source of the project.
- At its root directory run `make build`. Copy
- Move `.build/release/clue` to desired location in your `PATH`.

## Command-line Usage

To **find** symbol references of `XYZ` in your project, first build it with either Xcode, or SwiftPM. If it's
built with Xcode, run the following:

```
clue find XYZ
```

You can include a module name, and/or symbol's *kind* to disambiguate multiple potential matches:

```
# look for references of protocol `XYZ` in module `XYZModule`

clue find --swiftpm path/to/swiftpm/project XYZ --module XYZModule --kind protocol
```

You can also **dump** all symbols defined in a module of certain kinds:

```
# look for enums defined in module `in module `XYZModule`, output in JSON format

clue dump XYZModule --kinds enum --output json
```

For more details, read `clue --help`. Read the [Advanced User Guide][] more in-depth discussion on how
everything works behind the scenes.

[Advanced User Guide]: ./AdvancedUserGuide.md
