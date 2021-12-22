import ArgumentParser

// clue --xcode Lyft libIndexStore

struct CLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "clue",
        abstract: "Looking for Swift symbol references in a Swift project."
    )

    @Option(
        help: ArgumentHelp(
            "Location of libIndexStore",
            valueName: "path to libIndexStore"
        )
    )
    var lib = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"

    @Option(
        help: ArgumentHelp(
            "Path to index store",
            valueName: "path to index store"
        )
    )
    var store: String?

    @Option(
        help: ArgumentHelp(
            "Name of an Xcode project.",
            valueName: "Xcode project name"
        )
    )
    var xcode: String?

    @Option(
        help: ArgumentHelp(
            "Path to an SwiftPM project.",
            valueName: "SwiftPM project location"
        )
    )
    var swiftpm: String?

    @Flag(help: "Look for read references.")
    var read = false

    @Flag(help: "Look for write references.")
    var write = false

    @Flag(help: "Look for definition.")
    var definition = false

    @Argument(help: "Symbol to look for.")
    var symbol: String
}
