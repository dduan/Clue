import IndexStoreDB

public struct Finding {
    public enum Details {
        case find(
            query: ReferenceQuery,
            definition: SymbolOccurrence,
            occurrences: [SymbolOccurrence]
        )

        case dump(
            query: ModuleQuery,
            definitions: [SymbolOccurrence]
        )
    }

    public let libIndexStore: String
    public let storeLocation: String
    public let details: Details
}
