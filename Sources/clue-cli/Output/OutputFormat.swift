enum OutputFormat {
    case readable(colored: Bool)
    case csv
    case json
}

extension OutputFormat {
    init?(_ string: String) {
        switch string.lowercased() {
        case "readable-colored":
            self = .readable(colored: true)
        case "readable":
            self = .readable(colored: false)
        case "csv":
            self = .csv
        case "json":
            self = .json
        default:
            return nil
        }
    }
}

extension OutputFormat: CaseIterable {
    static var allCases: [OutputFormat] {
        [
            .readable(colored: true),
            .readable(colored: false),
            .csv,
            .json
        ]
    }
}

extension OutputFormat: CustomStringConvertible {
    var description: String {
        switch self {
        case .readable(colored: true):
            return "readable-colored"
        case .readable(colored: false):
            return "readable"
        case .csv:
            return "csv"
        case .json:
            return "json"
        }
    }
}
