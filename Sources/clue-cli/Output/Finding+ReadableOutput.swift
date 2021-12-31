import Clue

extension Finding {
    func readableOutput(colored: Bool) -> String {
        self.occurrences
            .map { $0.locationString }
            .joined(separator: "\n")
    }
}

