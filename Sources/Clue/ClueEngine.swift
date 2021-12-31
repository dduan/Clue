import IndexStoreDB
import Pathos

public struct ClueEngine {
    let db: IndexStoreDB
    let libPath: String
    let storeLocation: StoreLocation
    /// - throws: StoreInitializationError
    public init(libIndexStorePath: String? = nil, _ storeLocation: StoreLocation) throws {
        let libIndexStore: IndexStoreLibrary
        do {
            self.libPath = try libIndexStorePath ?? defaultPathToLibIndexStore()
            libIndexStore = try IndexStoreLibrary(dylibPath: libPath)
        } catch let error as StoreInitializationError {
            throw error
        } catch let error {
            throw StoreInitializationError.invalidLibIndexStore(error)
        }

        let storePath = try storeLocation.resolveIndexStorePath()
        guard let indexStore = try? IndexStoreDB(
            storePath: storePath,
            databasePath: "\(try Path.makeTemporaryDirectory())",
            library: libIndexStore
        ) else {
            throw StoreInitializationError.invalidIndexStore
        }

        indexStore.pollForUnitChangesAndWait()

        self.storeLocation = storeLocation
        self.db = indexStore
    }

    public func execute(_ query: Query) throws -> Finding {
        let role = Query.Role.specific(
            role: query.role.positive.isEmpty ? .all : query.role.positive,
            negativeRole: query.role.negative
        )

        let definition = try self.findDefinition(from: query.usr)
        let result = db.occurrences(ofUSR: definition.symbol.usr, roles: role.positive)
            .filter { !$0.roles.isSuperset(of: [.implicit, .definition]) }
            .filter { $0.roles.isDisjoint(with: role.negative.union(.definition)) }

        return .init(
            libIndexStore: self.libPath,
            storeLocation: self.storeLocation,
            usrQuery: query.usr,
            referenceRole: role,
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
            throw Failure.symbolNotFound(byName: symbolName)
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
                throw Failure.symbolNotFound(byUSR: usr)
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
        case symbolNotFound(byName: String)
        case symbolNotFound(byUSR: String)
    }
}
