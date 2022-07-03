import IndexStoreDB
public struct ModuleQuery {
    public let name: String
    public let kinds: [IndexSymbolKind]

    public init(name: String, kinds: [IndexSymbolKind]) {
        self.name = name
        self.kinds = kinds
    }
}
