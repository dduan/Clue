import Clue
import IsTTY

extension Finding {
    func description(for format: OutputFormat) -> String {
        switch format {
        case .automatic:
            return self.readableOutput(colored: IsTTY.standardOutput)
        case .readable:
            return self.readableOutput(colored: false)
        case .colored:
            return self.readableOutput(colored: true)
        case .csv:
            return self.csv()
        case .tsv:
            return self.tsv()
        case .json:
            return self.json()
        case .files:
            return self.filePaths()
        }
    }
}
