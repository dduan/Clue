import IndexStoreDB
import Pathos

public enum ClueEngine {
    public enum Failure: Error {
        case ambiguousSymbol([SymbolOccurrence])
        case symbolNotFound
    }

    public struct Query {
        public let store: StoreQuery
        public let usr: USRQuery
        public let reference: ReferenceQuery

        public init(store: StoreQuery, usr: USRQuery, reference: ReferenceQuery) {
            self.store = store
            self.usr = usr
            self.reference = reference
        }
    }

    public struct Finding {
        public let storeQuery: StoreQuery
        public let usrQuery: USRQuery
        public let referenceQuery: ReferenceQuery
        public let occurrences: [SymbolOccurrence]
    }

    static func loadIndexStore(_ query: StoreQuery) throws -> IndexStoreDB {
        guard let libIndexStore = try? IndexStoreLibrary(dylibPath: query.libIndexStore) else {
            throw StoreQuery.Failure.invalidLibIndexStore
        }

        let storePath = try query.location.resolveIndexStorePath()
        guard let indexStore = try? IndexStoreDB(
            storePath: storePath,
            databasePath: "\(try Path.makeTemporaryDirectory())",
            library: libIndexStore
        ) else {
            throw StoreQuery.Failure.invalidIndexStore
        }

        indexStore.pollForUnitChangesAndWait()

        return indexStore
    }

    /// Find definitions, among them, find matching modules and types if any
    static func inferReferenceQuerySymbol(db: IndexStoreDB, _ query: USRQuery) throws -> Symbol {
        let defs = db
            .canonicalOccurrences(
                containing: query.symbol,
                anchorStart: true,
                anchorEnd: false,
                subsequence: false,
                ignoreCase: false
            )
            .filter { $0.roles.contains(.definition) }
            .filter { d in query.module.map { d.symbol.usr.contains($0) } ?? true  }
            .filter { d in query.symbolKind.map { d.symbol.kind == $0 } ?? true }
        if defs.count > 1 {
            throw Failure.ambiguousSymbol(defs)
        } else if defs.isEmpty {
            throw Failure.symbolNotFound
        }

        return defs[0].symbol
    }

    static func inferReferenceQueryRole(db: IndexStoreDB, fromUSR usr: String) throws -> ReferenceQuery {
        guard let symbol = db.occurrences(ofUSR: usr, roles: .definition).first?.symbol else {
            throw Failure.symbolNotFound
        }

        return try self.inferReferenceQueryRole(db: db, from: symbol)
    }

    static func inferReferenceQueryRole(db: IndexStoreDB, from symbol: Symbol) throws -> ReferenceQuery {
        switch symbol.kind {
        case .variable:
            return .init(
                usrs: [
                    symbol.usr,
                    db.canonicalOccurrences(ofName: "getter:\(symbol.name)").first?.symbol.usr,
                    db.canonicalOccurrences(ofName: "setter:\(symbol.name)").first?.symbol.usr,
                ].compactMap { $0 },
                role: [.definition, .call],
                negativeRole: []
            )
        default:
            return .init(usrs: [symbol.usr], role: .all, negativeRole: [])
        }
    }

    public static func execute(_ query: Query) throws -> Finding {
        let db = try loadIndexStore(query.store)
        let referenceQuery = try self.buildReferenceQuery(db: db, from: query)
        let result = referenceQuery
            .usrs
            .flatMap { usr in db.occurrences(ofUSR: usr, roles: referenceQuery.role) }
            .filter { !$0.roles.isSuperset(of: [.implicit, .definition]) }
            .filter { $0.roles.isDisjoint(with: referenceQuery.negativeRole) }

        return .init(
            storeQuery: query.store,
            usrQuery: query.usr,
            referenceQuery: referenceQuery,
            occurrences: result
        )
    }

    static func buildReferenceQuery(db: IndexStoreDB, from query: Query) throws -> ReferenceQuery {
        if query.reference.usrs.isEmpty {
            let inferredSymbol = try self.inferReferenceQuerySymbol(db: db, query.usr)
            let inferredReference = try self.inferReferenceQueryRole(db: db, from: inferredSymbol)
            let negativeRole = query.reference.negativeRole.isEmpty
                ? inferredReference.negativeRole
                : query.reference.negativeRole
            return .init(
                usrs: inferredReference.usrs,
                role: query.reference.role.isEmpty ? inferredReference.role : query.reference.role,
                negativeRole: negativeRole
            )
        } else {
            return .init(
                usrs: query.reference.usrs,
                role: query.reference.role.isEmpty ? .all : query.reference.role,
                negativeRole: query.reference.negativeRole.isEmpty ? [] : query.reference.negativeRole
            )
        }
    }
}
