import Clue
import IndexStoreDB

extension Finding {
    private func format(_ occurrences: [SymbolOccurrence]) -> String {
        let paths = occurrences
            .map { $0.location.path }
        return Set(paths)
            .sorted()
            .joined(separator: "\n")
    }

    func filePaths() -> String {
        switch self.details {
        case .find(_, let definition, let occurrences):
            return format([definition] + occurrences)
        case .dump(_, let definitions):
            return format(definitions)
        }
    }
}
