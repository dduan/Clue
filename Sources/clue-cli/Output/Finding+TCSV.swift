import Clue
import IndexStoreDB

extension Finding {
    private func format(_ occurrences: [SymbolOccurrence], valueSeparator: String, addHeader: Bool) -> String {
        let header = ["name", "usr", "kind", "roles", "path", "line", "column", "moduleName", "isSystem"]
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

        return ((addHeader ? [header] : []) + content)
            .map { $0.joined(separator: valueSeparator) }
            .joined(separator: "\n")
    }

    func csv(includeHeader: Bool) -> String {
        let separator = ","
        switch self.details {
        case .find(_, _, let occurrences):
            return format(occurrences, valueSeparator: separator, addHeader: includeHeader)
        case .dump(_, let definitions):
            return format(definitions, valueSeparator: separator, addHeader: includeHeader)
        }
    }

    func tsv(includeHeader: Bool) -> String {
        let separator = "\t"
        switch self.details {
        case .find(_, _, let occurrences):
            return format(occurrences, valueSeparator: separator, addHeader: includeHeader)
        case .dump(_, let definitions):
            return format(definitions, valueSeparator: separator, addHeader: includeHeader)
        }
    }
}
