import Clue
import IndexStoreDB

do {
    let r = try Clue.ClueEngine.execute(
        .init(
            store: .init(libIndexStore: options.lib ?? (try! defaultPathToLibIndexStore()), location: .swiftpm(path: options.swiftpm ?? "")),
            usr: .init(symbol: options.symbol, module: nil, symbolKind: nil),
            reference: .empty
        )
    )

    r.occurrences.map { "\($0.location.path):\($0.location.line):\($0.location.utf8Column):\($0.symbol.kind)" }.forEach { print($0) }
} catch let error {
    print(error)
}

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

func indexStoreLocation(from options: Options) -> StoreQuery.Location {
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

func referenceQueryRole(from options: Options) -> ReferenceQuery.Role {
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

extension ClueEngine.Query {
    init(_ options: Options) {
        self.init(
            store: .init(
                libIndexStore: libIndexStorePath(from: options),
                location: indexStoreLocation(from: options)
            ),
            usr: .init(
                symbol: options.symbol,
                module: options.module,
                symbolKind: symbolKindFrom(options)
            ),
            reference: .init(
                usrs: options.usrs,
                role: referenceQueryRole(from: options)
            )
        )
    }
}

func main(_ options: Options) {
    do {
        let result = try ClueEngine.execute(.init(options))
        print(result)
    } catch let error {
        print(error)
    }
}

main(options)
