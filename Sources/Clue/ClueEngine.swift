import IndexStoreDB
import Pathos

public enum ClueEngine {
    public enum Failure: Error {
        case ambiguousSymbol([SymbolOccurrence])
        case symbolNotFound(byName: String)
        case symbolNotFound(byUSR: String)
    }


    public struct Finding {
        public let storeQuery: Query.Store
        public let usrQuery: Query.USR
        public let referenceRole: Query.Role
        public let definition: SymbolOccurrence
        public let occurrences: [SymbolOccurrence]
    }

    static func loadIndexStore(_ query: Query.Store) throws -> IndexStoreDB {
        guard let libIndexStore = try? IndexStoreLibrary(dylibPath: query.libIndexStore) else {
            throw Query.Store.Failure.invalidLibIndexStore
        }

        let storePath = try query.location.resolveIndexStorePath()
        guard let indexStore = try? IndexStoreDB(
            storePath: storePath,
            databasePath: "\(try Path.makeTemporaryDirectory())",
            library: libIndexStore
        ) else {
            throw Query.Store.Failure.invalidIndexStore
        }

        indexStore.pollForUnitChangesAndWait()

        return indexStore
    }

    /// Find occurence for a definition associated with the symbolName, module, and kind.
    static func inferReferenceQuerySymbol(
        db: IndexStoreDB,
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

    public static func execute(_ query: Query) throws -> Finding {
        // TODO: this is very inefficient for mulitple queries.
        let db = try loadIndexStore(query.store)
        let role = Query.Role.specific(
            role: query.role.positive.isEmpty ? .all : query.role.positive,
            negativeRole: query.role.negative
        )

        let definition = try self.findDefinition(db: db, from: query.usr)
        let result = db.occurrences(ofUSR: definition.symbol.usr, roles: role.positive)
            .filter { !$0.roles.isSuperset(of: [.implicit, .definition]) }
            .filter { $0.roles.isDisjoint(with: role.negative.union(.definition)) }

        return .init(
            storeQuery: query.store,
            usrQuery: query.usr,
            referenceRole: role,
            definition: definition,
            occurrences: result
        )
    }

    /// Return a definition for the given USR query
    static func findDefinition(db: IndexStoreDB, from query: Query.USR) throws -> SymbolOccurrence {
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
                db: db,
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
