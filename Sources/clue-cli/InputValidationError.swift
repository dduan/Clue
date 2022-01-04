enum InputValidationError: Error {
    case couldNotInferLibIndexPath
    case missingStoreLocation
    case mutuallyExclusive(String, String)
    case invalidValues(String, [String])
    case missingSymbol
}

extension InputValidationError: CustomStringConvertible {
    var description: String {
        switch self {
        case .couldNotInferLibIndexPath:
            return "Failed searching for Swift toolchain. Please provide value for --lib"
        case .missingStoreLocation:
            return "Please provide value for one of --store, --xcode, or --swiftpm."
        case .mutuallyExclusive(let option1, let option2):
            return "\(option1) and \(option2) are mutually exclusive."
        case .invalidValues(let option, let problems):
            return "Invalid value for \(option): \(problems.joined(separator: ", "))"
        case .missingSymbol:
            return "Please provide either a symbol name or --usr"
        }
    }
}
