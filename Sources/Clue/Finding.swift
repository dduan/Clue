import IndexStoreDB

public struct Finding {
    public let libIndexStore: String
    public let storeLocation: StoreLocation
    public let query: Query
    public let definition: SymbolOccurrence
    public let occurrences: [SymbolOccurrence]
}
