import Clue
import Chalk

extension Finding {
    func readableOutput(colored: Bool) -> String {
        colored ? self.outputColored() : self.outputMono()
    }

    private func outputColored() -> String {
        self.occurrences
            .map { "\($0.location.path):\($0.location.line, color: .green):\($0.location.utf8Column)" }
            .joined(separator: "\n")
    }

    private func outputMono() ->String {
        self.occurrences
            .map { $0.locationString }
            .joined(separator: "\n")
    }
}
