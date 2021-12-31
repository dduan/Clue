import IndexStoreDB

public struct Finding {
    public let libIndexStore: String
    public let storeLocation: StoreLocation
    public let usrQuery: Query.USR
    public let referenceRole: Query.Role
    public let definition: SymbolOccurrence
    public let occurrences: [SymbolOccurrence]
}
