import IndexStoreDB
import Pathos

public struct ClueEngine {
    let db: IndexStoreDB
    let libPath: String
    let storePath: String
    /// - throws: StoreInitializationError
    public init(libIndexStorePath: String? = nil, storeLocation: StoreLocation? = nil) throws {
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

        let storePath = try (storeLocation ?? Self.inferStoreLocation()).resolveIndexStorePath()
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
        switch query {
        case .find(let query):
            let role = ReferenceQuery.Role.specific(
                role: query.role.inclusive.isEmpty ? .all : query.role.inclusive,
                exclusiveRole: query.role.exclusive
            )

            let definition = try self.findDefinition(from: query.usr)
            let result = db.occurrences(ofUSR: definition.symbol.usr, roles: role.inclusive)
                .filter { !$0.roles.isSuperset(of: [.implicit, .definition]) }
                .filter { $0.roles.isDisjoint(with: role.exclusive.union(.definition)) }
                .filter { !$0.location.isSystem }

            return .init(
                libIndexStore: self.libPath,
                storeLocation: self.storePath,
                details: .find(
                    query: .init(usr: query.usr, role: role),
                    definition: definition,
                    occurrences: result
                )
            )
        case .dump(let query):
            let kinds = query.kinds.isEmpty ? IndexSymbolKind.allCases : query.kinds
            let definitions = self.db.canonicalOccurrences(
                containing: "",
                anchorStart: true,
                anchorEnd: false,
                subsequence: false,
                ignoreCase: false
            )
            .filter { $0.roles.contains(.definition) }
            .filter { $0.location.moduleName == query.name }
            .filter { kinds.contains($0.symbol.kind) }
            return .init(
                libIndexStore: self.libPath,
                storeLocation: self.storePath,
                details: .dump(
                    query: query,
                    definitions: definitions
                )
            )
        }
    }


    /// Find occurrence for a definition associated with the symbolName, module, and kind.
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
            .filter { d in module.map { d.location.moduleName == $0 } ?? true  }
            .filter { d in kind.map { d.symbol.kind == $0 } ?? true }
        if candidates.count > 1 {
            throw Failure.ambiguousSymbol(candidates)
        } else if candidates.isEmpty {
            throw Failure.symbolNotFoundByName(symbolName)
        }

        return candidates[0]
    }

    /// Return a definition for the given USR query
    func findDefinition(from query: ReferenceQuery.USR) throws -> SymbolOccurrence {
        let definition: SymbolOccurrence
        switch query {
        case .explict(let usr, let isSystem):
            let candidates = self.db.occurrences(ofUSR: usr, roles: .definition)
                .filter { $0.location.isSystem == isSystem }
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

    static func inferStoreLocation() throws -> StoreLocation {
        do {
            if let workspace = (try Path("*.xcworkspace").glob()).first {
                return .inferFromXcodeProject(atPath: workspace.description)
            }

            if let xcodeproj = (try Path("*.xcodeproj").glob()).first {
                return .inferFromXcodeProject(atPath: xcodeproj.description)
            }

            if Path("Package.swift").exists() {
                return .inferFromSwiftPMProject(atPath: "./")
            }
        } catch let error {
            throw StoreInitializationError.filesystemError(error)
        }

        throw StoreInitializationError.couldNotInferStoreLocation
    }
}
