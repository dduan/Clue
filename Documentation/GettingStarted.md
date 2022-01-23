# Clue: Getting Started

## Installation

- Download source of the project.
- At its root directory run `make build`. Copy
- Move `.build/release/clue` to desired location in your `PATH`.

## Command-line Usage

To find symbol references of `XYZ` in your project, first build it with either Xcode, or SwiftPM. If it's
built with Xcode, run the following:

```
clue --xcode ProjectName XYZ
```

... if you build with SwiftPM use this instead:

```
clue --swiftpm path/to/swiftpm/project XYZ
```

You can include a module name, and/or symbol's *kind* to disambiguate multiple potential matches:

```
# look for references of protocol `XYZ` in module `XYZModule`

clue --swiftpm path/to/swiftpm/project XYZ --module XYZModule --kind protocol ```
```

For more details, read `clue --help`. Read the [Advanced User Guide][] more in-depth discussion on how
everything works behind the scenes.

[Advanced User Guide]: ./AdvancedUserGuide.md
