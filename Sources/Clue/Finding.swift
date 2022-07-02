import IndexStoreDB

public struct Finding {
    public let libIndexStore: String
    public let storeLocation: String
    public let query: ReferenceQuery
    public let definition: SymbolOccurrence
    public let occurrences: [SymbolOccurrence]
}
