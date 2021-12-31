import Clue

extension Finding {
    func description(for format: OutputFormat) -> String {
        switch format {
        case .readable(let isColored):
            return self.readableOutput(colored: isColored)
        case .csv:
            return self.csv()
        case .json:
            return self.json()
        }
    }
}
