import IndexStoreDB

extension SymbolOccurrence {
    public var locationString: String {
        let l = self.location
        return "\(l.path):\(l.line):\(l.utf8Column)"
    }
}
