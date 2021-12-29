import IndexStoreDB

extension SymbolOccurrence {
    public var locationString: String {
        "\(self.location.path):\(self.location.line):\(self.location.utf8Column)"
    }
}
