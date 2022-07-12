import Clue
import IsTTY

extension Finding {
    func description(for format: OutputFormat, includeHeader: Bool) -> String {
        switch format {
        case .automatic:
            return self.readableOutput(colored: IsTTY.standardOutput)
        case .readable:
            return self.readableOutput(colored: false)
        case .colored:
            return self.readableOutput(colored: true)
        case .csv:
            return self.csv(includeHeader: includeHeader)
        case .tsv:
            return self.tsv(includeHeader: includeHeader)
        case .json:
            return self.json()
        case .files:
            return self.filePaths()
        }
    }
}
