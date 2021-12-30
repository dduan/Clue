import IndexStoreDB

/// Information that help pinning down one or more USRs
public enum USRQuery {
    case explict(usr: String)
    case query(
        symbol: String,
        module: String? = nil,
        kind: IndexSymbolKind? = nil,
        isSystem: Bool
    )
}
