import Clue
import IndexStoreDB

func libIndexStorePath(from options: CommonOptions) throws -> String {
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

func referenceQueryRole(from options: CLI.Find) throws -> ReferenceQuery.Role {
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

func symbolKindFrom(_ options: CLI.Find) throws -> IndexSymbolKind? {
    if let kindString = options.symbolKind {
        guard let kind = IndexSymbolKind(kindString) else {
            throw InputValidationError.invalidValues("--symbol-kind", [kindString])
        }

        return kind
    } else {
        return nil
    }
}

func usrQuery(from options: CLI.Find) throws -> ReferenceQuery.USR {
    switch (options.usr, options.symbol) {
    case (nil, nil):
        throw InputValidationError.noSymbol
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

func storeLocation(from options: CommonOptions) throws -> StoreLocation? {
    switch (options.store, options.xcode, options.swiftpm) {
    case (nil, nil, nil):
        return nil
    case let (.some(store), _, _):
        return .some(.path(store))
    case (_, .some, .some):
        throw InputValidationError.bothXcodeAndSwiftPM
    case let (_, .some(xcode), _):
        return .some(.inferFromXcodeProject(atPath: xcode))
    case let (_, _, .some(swiftpm)):
        return .some(.inferFromSwiftPMProject(atPath: swiftpm))
    }
}

extension ReferenceQuery {
    init(_ options: CLI.Find) throws {
        self.init(
            usr: try usrQuery(from: options),
            role: try referenceQueryRole(from: options)
        )
    }
}

func moduleQueryKind(from options: CLI.Dump) throws -> [IndexSymbolKind] { [] }

extension ModuleQuery {
    init(_ options: CLI.Dump) throws {
        self.init(
            name: options.module,
            kinds: options.kinds
        )
    }
}

do {
    var parsed = try CLI.parseAsRoot()
    if let options = parsed as? CLI.Find {
        let engine = try ClueEngine(
            libIndexStorePath: try libIndexStorePath(from: options.common),
            storeLocation: try storeLocation(from: options.common)
        )
        let result = try engine.execute(.find(.init(options)))
        print(result.description(for: options.common.output))
    } else if let options = parsed as? CLI.Dump {
        let engine = try ClueEngine(
            libIndexStorePath: try libIndexStorePath(from: options.common),
            storeLocation: try storeLocation(from: options.common)
        )
        let result = try engine.execute(.dump(.init(options)))
        print(result.description(for: options.common.output))
    } else {
        try parsed.run()
    }
} catch let error {
    CLI.exit(withError: error)
}
