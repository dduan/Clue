import Clue
import IndexStoreDB

let options = Options.parseOrExit()

func libIndexStorePath(from options: Options) throws -> String {
    if let lib = options.lib {
        return lib
    } else {
        do {
            return try defaultPathToLibIndexStore()
        } catch {
            throw InputValidationError.couldNotInferLibIndexPath
        }
    }
}

func indexStoreLocation(from options: Options) throws -> StoreLocation {
    guard options.store != nil || options.xcode != nil || options.swiftpm != nil else {
        throw InputValidationError.missingStoreLocation
    }

    if let explicitStore = options.store {
        return .store(path: explicitStore)
    } else if let xcodeProjectName = options.xcode {
        return .xcode(projectName: xcodeProjectName)
    } else {
        return .swiftpm(path: options.swiftpm!)
    }
}

func referenceQueryRole(from options: Options) throws -> Query.Role {
    guard !(options.roleInstanceOnly && options.roleInheritanceOnly) else {
        throw InputValidationError.mutuallyExclusive("--role-reference-only", "--role-inheritance-only")
    }

    if options.roleInstanceOnly {
        return .preset(.instanceOnly)
    } else if options.roleInheritanceOnly {
        return .preset(.inheritanceOnly)
    } else { // add more above if we ever make more presets
        let (inclusive, inclusiveProblems) = SymbolRole.initialize(from: options.roles)
        if !inclusiveProblems.isEmpty {
            throw InputValidationError.invalidValues("--roles", inclusiveProblems)
        }

        let (exclusive, exclusiveProblems) = SymbolRole.initialize(from: options.excludeRoles)
        if !exclusiveProblems.isEmpty {
            throw InputValidationError.invalidValues("--exclude-roles", exclusiveProblems)
        }

        return .specific(role: inclusive, exclusiveRole: exclusive)
    }
}

func symbolKindFrom(_ options: Options) throws -> IndexSymbolKind? {
    if let kindString = options.symbolKind {
        guard let kind = IndexSymbolKind(kindString) else {
            throw InputValidationError.invalidValues("--symbol-kind", [kindString])
        }

        return kind
    } else {
        return nil
    }
}

func usrQueryFrom(_ options: Options) throws -> Query.USR {
    switch (options.usr, options.symbol) {
    case (nil, nil):
        bail("Please provide either a symbol name or --usr")
    case let (nil, .some(symbolName)):
        return .query(
            symbol: symbolName,
            module: options.module,
            kind: try symbolKindFrom(options),
            isSystem: options.isSystem,
            strictSymbolLookup: options.strictSymbolLookup
        )
    case let (.some(usr), nil):
        return .explict(usr: usr)
    case _:
        throw InputValidationError.mutuallyExclusive("Symbol name", "--usr")
    }
}

extension Query {
    init(_ options: Options) throws {
        self.init(
            usr: try usrQueryFrom(options),
            role: try referenceQueryRole(from: options)
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
        print(result.description(for: options.output))
    } catch let error {
        bail("\(error)")
    }
}

main(options)
