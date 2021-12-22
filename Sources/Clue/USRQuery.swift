import IndexStoreDB

/// Information that help pinning down one or more USRs
public struct USRQuery {
    var symbol: String
    var module: String?
    var symbolKind: IndexSymbolKind?

    public init(symbol: String, module: String? = nil, symbolKind: IndexSymbolKind? = nil) {
        self.symbol = symbol
        self.module = module
        self.symbolKind = symbolKind
    }
}
