import IndexStoreDB
public struct ModuleQuery {
    let name: String
    let kinds: [IndexSymbolKind]

    public init(name: String, kinds: [IndexSymbolKind]) {
        self.name = name
        self.kinds = kinds
    }
}
