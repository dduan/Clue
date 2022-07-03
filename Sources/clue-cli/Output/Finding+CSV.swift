import Clue
import IndexStoreDB

extension Finding {
    func csv() -> String {
        let header = ["name", "usr", "kind", "roles", "path", "line", "column", "moduleName", "isSystem"]
        switch self.details {
        case .find(_, _, let occurrences):
            let content = occurrences
            .map { (occur: SymbolOccurrence) -> [String] in
                [
                    occur.symbol.name,
                    occur.symbol.usr,
                    occur.symbol.kind.description,
                    occur.roles.description,
                    occur.location.path,
                    occur.location.line.description,
                    occur.location.utf8Column.description,
                    occur.location.moduleName,
                    occur.location.isSystem.description,
                ]
            }

            return ([header] + content)
            .map { $0.joined(separator: ",") }
            .joined(separator: "\n")
        case .dump:
            fatalError("Implement me") // TODO
        }
    }
}
