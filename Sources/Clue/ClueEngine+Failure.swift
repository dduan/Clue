import IndexStoreDB

extension ClueEngine {
    public enum Failure: Error {
        case ambiguousSymbol([SymbolOccurrence])
        case symbolNotFoundByName(String)
        case symbolNotFoundByUSR(String)
    }
}

extension ClueEngine.Failure: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ambiguousSymbol(let occurrences):
            return "Found more than one symbol matching your input. "
                + "Pick one from the following with more details (full name, --module, and/or --kind):\n\n"
                + occurrences
                    .map { $0.errorDescription }
                    .joined(separator: "\n\n")
        case .symbolNotFoundByName(let name):
            return "Could not find a symbol matching name '\(name)'"
        case .symbolNotFoundByUSR(let usr):
            return "Could not find a symbol matching USR '\(usr)'"
        }
    }
}

extension SymbolOccurrence {
    fileprivate var errorDescription: String {
        """
        | Name     | \(self.symbol.name)
        | Module   | \(self.location.moduleName)
        | Kind     | \(self.symbol.kind)
        | USR      | \(self.symbol.usr)
        | Location | \(self.locationString)
        """
    }
}
