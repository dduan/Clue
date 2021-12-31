import IndexStoreDB

public struct Finding {
    public let storeQuery: Query.Store
    public let usrQuery: Query.USR
    public let referenceRole: Query.Role
    public let definition: SymbolOccurrence
    public let occurrences: [SymbolOccurrence]
}
