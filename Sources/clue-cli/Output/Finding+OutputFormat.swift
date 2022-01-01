import Clue

extension Finding {
    func description(for format: OutputFormat) -> String {
        switch format {
        case .automatic:
            return self.readableOutput(colored: true) // TODO: `false` if not writing to a tty
        case .readable:
            return self.readableOutput(colored: false)
        case .csv:
            return self.csv()
        case .json:
            return self.json()
        }
    }
}
