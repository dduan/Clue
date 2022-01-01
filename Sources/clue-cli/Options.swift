import ArgumentParser
import IndexStoreDB

// TODO: There should be a way to run mulitple queries within a single command-line process.
//       Probably via a input file that deserializes to [ClueEngine.Query].

struct Options: ParsableCommand {
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
    var roleInstanceOnly = false

    @Flag(help: "Filter result for class or protocol inheritance/conformance only (role = baseOf).")
    var roleInheritanceOnly = false

    @Option(help: "The USR for the symbol to look for. Cannot be used with `symbol` at the same time.")
    var usr: String?

    @Option(help: "Module where `symbol` is defined.")
    var module: String?

    @Option(help: "Kind of `symbol`.")
    var symbolKind: String?

    @Flag(help: "Whether `symbol` is a system symbol.")
    var isSystem: Bool = false

    @Flag(help: "Treat `symbol` as full name. Note for functions this include parameters like f(a:b:)")
    var strictSymbolLookup: Bool = false

    @Argument(help: "Name of a symbol to look for. Cannot be used with `usr` at the same time.")
    var symbol: String?

    @Option(help: "Output format. Either 'automatic' (default), 'readable', json' or 'csv'")
    var output: OutputFormat = .automatic
}

// TODO: some of the strings could be an enum, for which we could benefit from ArgumentParser.

extension OutputFormat: ExpressibleByArgument {}
extension SymbolRole: ExpressibleByArgument {}
