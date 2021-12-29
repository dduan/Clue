import IndexStoreDB

// TODO: this sholud be an enum with a case .explicit(usrs: [String])
/// Information that help pinning down one or more USRs
public struct USRQuery {
    var symbol: String
    var module: String?
    var symbolKind: IndexSymbolKind?
    // TODO: var isSystem: Bool = false

    public init(symbol: String, module: String? = nil, symbolKind: IndexSymbolKind? = nil) {
        self.symbol = symbol
        self.module = module
        self.symbolKind = symbolKind
    }
}
