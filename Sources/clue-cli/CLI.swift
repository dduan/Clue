import ArgumentParser

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
    var lib: String?

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

    @Option(help: "Instruct IndexStoreDB to search for symbols with these roles")
    var roles: [String] = []

    @Option(help: "Exclude these roles from IndexStoreDB results.")
    var excludeRoles: [String] = []

    @Flag(help: "Filter result for class or protocol consumption only (role = all, excludeRole = baseOf).")
    var roleReferenceOnly = false

    @Flag(help: "Filter result for class or protocol inheritance/conformance only (role = baseOf).")
    var roleInheritanceOnly = false

    @Argument(help: "Symbol to look for.")
    var symbol: String
}
