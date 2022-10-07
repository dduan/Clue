import IndexStoreDB

extension ReferenceQuery {
    /// Information that help pinning down one or more USRs
    public enum USR {
        case explict(
            usr: String,
            isSystem: Bool
        )
        case query(
            symbol: String,
            module: String? = nil,
            kind: IndexSymbolKind? = nil,
            isSystem: Bool,
            strictSymbolLookup: Bool
        )
    }
}
