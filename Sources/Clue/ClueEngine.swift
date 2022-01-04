import IndexStoreDB
import Pathos

public struct ClueEngine {
    let db: IndexStoreDB
    let libPath: String
    let storePath: String
    /// - throws: StoreInitializationError
    public init(libIndexStorePath: String? = nil, _ storeLocation: StoreLocation) throws {
        do {
            self.libPath = try libIndexStorePath ?? defaultPathToLibIndexStore()
        } catch let error {
            throw StoreInitializationError.filesystemError(error)
        }

        let libIndexStore: IndexStoreLibrary
        do {
            libIndexStore = try IndexStoreLibrary(dylibPath: libPath)
        } catch let error {
            throw StoreInitializationError.invalidLibIndexStore(libPath, error)
        }

        let storePath = try storeLocation.resolveIndexStorePath()
        var tempPath: String = ""
        do {
            tempPath = (try Path.makeTemporaryDirectory()).description
        } catch let error {
            throw StoreInitializationError.filesystemError(error)
        }

        guard let indexStore = try? IndexStoreDB(
            storePath: storePath,
            databasePath: tempPath,
            library: libIndexStore
        ) else {
            throw StoreInitializationError.invalidIndexStore
        }

        indexStore.pollForUnitChangesAndWait()

        self.storePath = storePath
        self.db = indexStore
    }

    public func execute(_ query: Query) throws -> Finding {
        let role = Query.Role.specific(
            role: query.role.inclusive.isEmpty ? .all : query.role.inclusive,
            exclusiveRole: query.role.exclusive
        )

        let definition = try self.findDefinition(from: query.usr)
        let result = db.occurrences(ofUSR: definition.symbol.usr, roles: role.inclusive)
            .filter { !$0.roles.isSuperset(of: [.implicit, .definition]) }
            .filter { $0.roles.isDisjoint(with: role.exclusive.union(.definition)) }

        return .init(
            libIndexStore: self.libPath,
            storeLocation: self.storePath,
            query: .init(usr: query.usr, role: role),
            definition: definition,
            occurrences: result
        )
    }


    /// Find occurence for a definition associated with the symbolName, module, and kind.
    func inferReferenceQuerySymbol(
        symbolName: String,
        module: String?,
        kind: IndexSymbolKind?,
        isSystem: Bool,
        strictSymbolLookup: Bool
    ) throws -> SymbolOccurrence {
        let candidates = db
            .canonicalOccurrences(
                containing: symbolName,
                anchorStart: true,
                anchorEnd: strictSymbolLookup,
                subsequence: false,
                ignoreCase: false
            )
            .filter { $0.roles.contains(.definition) && $0.location.isSystem == isSystem }
            .filter { d in module.map { d.symbol.usr.contains($0) } ?? true  }
            .filter { d in kind.map { d.symbol.kind == $0 } ?? true }
        if candidates.count > 1 {
            throw Failure.ambiguousSymbol(candidates)
        } else if candidates.isEmpty {
            throw Failure.symbolNotFoundByName(symbolName)
        }

        return candidates[0]
    }

    /// Return a definition for the given USR query
    func findDefinition(from query: Query.USR) throws -> SymbolOccurrence {
        let definition: SymbolOccurrence
        switch query {
        case .explict(let usr):
            let candidates = db.occurrences(ofUSR: usr, roles: .definition)
            guard !candidates.isEmpty else {
                throw Failure.symbolNotFoundByUSR(usr)
            }

            definition = candidates[0]
        case .query(let symbol, let module, let kind, let isSystem, let strictSymbolLookup):
            definition = try self.inferReferenceQuerySymbol(
                symbolName: symbol,
                module: module,
                kind: kind,
                isSystem: isSystem,
                strictSymbolLookup: strictSymbolLookup
            )
        }

        return definition
    }
}

extension ClueEngine {
    public enum Failure: Error {
        case ambiguousSymbol([SymbolOccurrence])
        case symbolNotFoundByName(String)
        case symbolNotFoundByUSR(String)
    }
}

extension ClueEngine.Failure: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ambiguousSymbol(let occurrences):
            return "Found more than one symbol matching your input. "
                + "Pick one from the following with more details (full name, --module, and/or --kind):\n"
                + occurrences
                    .map { "\($0.symbol.name) (\($0.symbol.kind)) at \($0.locationString)" }
                    .joined(separator: "\n")
        case .symbolNotFoundByName(let name):
            return "Could not find a symbol matching name '\(name)'"
        case .symbolNotFoundByUSR(let usr):
            return "Could not find a symbol matching USR '\(usr)'"
        }
    }
}
