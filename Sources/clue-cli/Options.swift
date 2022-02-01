import ArgumentParser
import IndexStoreDB

// TODO: There should be a way to run mulitple queries within a single command-line process.
//       Probably via a input file that deserializes to [ClueEngine.Query].

struct Options: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "clue",
        abstract: "Find symbol references in a Swift project."
    )

    @Option(
        help: ArgumentHelp(
            "Location of libIndexStore. By default, this value is inferred from your current Swift runtime.",
            valueName: "path to libIndexStore"
        )
    )
    var lib: String?

    @Option(
        help: ArgumentHelp(
            "Direct path to the index store of your project. Use this option if your project has a non-standard location for its index. Otherwise, use --xcode for Xcode-bulit projects, or --swiftpm for SwiftPM built projects.",
            valueName: "path to a Swift project's index store"
        )
    )
    var store: String?

    @Option(
        help: ArgumentHelp(
            "Clue will attempt to infer the location of the index store from the project's derived data. Use the  Alternatively, use --swiftpm if you build with SwiftPM command-line; use --store to specify the precise location of your index store.",
            valueName: "Path to Xcode's .xcodeproj or .xcworkspace"
        )
    )
    var xcode: String?

    @Option(
        help: ArgumentHelp(
            "A SwiftPM project's location on the file system. The index store location will be inferred assuming the index is built directly via SwiftPM command, in the debug configuration. Alternatively: use --xcode if the project (SwiftPM or not) is built by Xcode; use --store to specify the precise location of your index store.",
            valueName: "Path to a project built by SwiftPM."
        )
    )
    var swiftpm: String?

    @Option(help: "Filter results references by including these roles. Valid roles are: \(SymbolRole.allCases.map { $0.description }.joined(separator: ", ")). (default: all)")
    var roles: [String] = []

    @Option(help: "Exclude results with these roles roles. See --roles for valid values. (default: none)")
    var excludeRoles: [String] = []

    @Flag(help: "Filter result for class or protocol consumption only (role = all, excludeRole = baseOf).")
    var roleInstanceOnly = false

    @Flag(help: "Filter result for class or protocol inheritance/conformance only (role = baseOf).")
    var roleInheritanceOnly = false

    @Option(help: "The \"Unified Symbol Resolution\" for the symbol to look for. Use this option to replace `symbol`, in case it is ambiguous.")
    var usr: String?

    @Option(help: "Module where `symbol` is defined. Use this option if Clue `symbol` is ambiguous.")
    var module: String?

    @Option(help: "Kind of `symbol`. Use this option if Clue `symbol` is ambiguous. Valid kinds are: \(IndexSymbolKind.allCases.map { "\($0)" }.joined(separator: ", ")).")
    var symbolKind: String?

    @Flag(help: "Whether `symbol` is a system symbol. Use this option if Clue `symbol` is ambiguous. (default: false)")
    var isSystem: Bool = false

    @Flag(help: "Treat `symbol` as full name instead of a prefix. Note for functions this include parameters like f(a:b:).")
    var strictSymbolLookup: Bool = false

    @Argument(help: "Prefix of a symbol to search for. Cannot be used with --usr at the same time.")
    var symbol: String?

    @Option(help: "Output format. By default (automatic), the output is 'colored' for terminals, and 'readable' for non-terminal. Valid options are: automatic, readable, colored, json, csv, files.")
    var output: OutputFormat = .automatic
}

extension OutputFormat: ExpressibleByArgument {}
