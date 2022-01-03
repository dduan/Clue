import Clue

extension Finding {
    func filePaths() -> String {
        let paths = ([self.definition] + self.occurrences)
            .map { $0.location.path }
        return Set(paths)
            .sorted()
            .joined(separator: "\n")
    }
}
