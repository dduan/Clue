import Clue
import IndexStoreDB

let options = Options.parseOrExit()

func libIndexStorePath(from options: Options) -> String {
    if let lib = options.lib {
        return lib
    } else {
        do {
            return try defaultPathToLibIndexStore()
        } catch {
            bail("Failed searching for Swift toolchain. Please provide value for --lib")
        }
    }
}

func indexStoreLocation(from options: Options) -> StoreLocation {
    // TODO: Infer something if all of these are missing?
    guard options.store != nil || options.xcode != nil || options.swiftpm != nil else {
        bail("Please provide value for one of --store, --xcode, or --swiftpm.")
    }

    if let explicitStore = options.store {
        return .store(path: explicitStore)
    } else if let xcodeProjectName = options.xcode {
        return .xcode(projectName: xcodeProjectName)
    } else {
        return .swiftpm(path: options.swiftpm!)
    }
}

func referenceQueryRole(from options: Options) -> Query.Role {
    guard !(options.roleInstanceOnly && options.roleInheritanceOnly) else {
        bail("--role-reference-only and --role-inheritance-only are mutually exclusive.")
    }

    if options.roleInstanceOnly {
        return .preset(.instanceOnly)
    } else if options.roleInheritanceOnly {
        return .preset(.inheritanceOnly)
    } else { // add more above if we ever make more presets
        let (positive, positiveProblems) = SymbolRole.initialize(from: options.roles)
        if !positiveProblems.isEmpty {
            bail("Invalid role values: \(positiveProblems.joined(separator: ", "))")
        }

        let (negative, negativeProblems) = SymbolRole.initialize(from: options.excludeRoles)
        if !negativeProblems.isEmpty {
            bail("Invalid negative role values: \(negativeProblems.joined(separator: ", "))")
        }

        return .specific(role: positive, negativeRole: negative)
    }
}

func symbolKindFrom(_ options: Options) -> IndexSymbolKind? {
    if let kindString = options.symbolKind {
        guard let kind = IndexSymbolKind(kindString) else {
            bail("Invalid value for --symbol-kind: \(kindString)")
        }

        return kind
    } else {
        return nil
    }
}

func usrQueryFrom(_ options: Options) -> Query.USR {
    switch (options.usr, options.symbol) {
    case (nil, nil):
        bail("Please provide either a symbol name or --usr")
    case let (nil, .some(symbolName)):
        return .query(
            symbol: symbolName,
            module: options.module,
            kind: symbolKindFrom(options),
            isSystem: options.isSystem,
            strictSymbolLookup: options.strictSymbolLookup
        )
    case let (.some(usr), nil):
        return .explict(usr: usr)
    case _:
        bail("Symbol name and --usr are mutually exclusive.")
    }
}

extension Query {
    init(_ options: Options) {
        self.init(
            usr: usrQueryFrom(options),
            role: referenceQueryRole(from: options)
        )
    }
}

func main(_ options: Options) {
    do {
        let engine = try ClueEngine(
            libIndexStorePath: libIndexStorePath(from: options),
            indexStoreLocation(from: options)
        )

        let result = try engine.execute(.init(options))
        for occur in result.occurrences {
            print(occur.locationString)
        }
    } catch let error {
        print(error)
    }
}

main(options)
