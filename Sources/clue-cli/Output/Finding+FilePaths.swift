import Clue

extension Finding {
    func filePaths() -> String {
        switch self.details {
        case .find(_, let definition, let occurrences):
        let paths = ([definition] + occurrences)
            .map { $0.location.path }
        return Set(paths)
            .sorted()
            .joined(separator: "\n")
        case .dump:
            fatalError("Implement me") // TODO
        }
    }
}
