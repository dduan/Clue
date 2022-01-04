public enum StoreInitializationError: Error {
    case multipleXcodeCandidates([String])
    case cannotFindXcode(at: String)
    case swiftpmDoesNotExist(at: String)
    case swiftpmWasNotBuiltInDebug(at: String)
    case filesystemError(Error)

    case invalidIndexStore
    case invalidLibIndexStore(String, Error)
}

extension StoreInitializationError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .multipleXcodeCandidates(let candidates):
            return "Found more than one potential match to your Xcode project. " 
                + "Try again with one of the following --xcode values:\n"
                + candidates.map { "  - \($0)" }
                    .joined(separator: "\n")
        case .cannotFindXcode(let path):
            return "Could not find derived data for an Xcode project at \(path)."
        case .swiftpmDoesNotExist(let path):
            return "The path \(path) does not exist."
        case .swiftpmWasNotBuiltInDebug(let path):
            return "Please build the project in debug configuration with SwiftPM: \(path)"
        case .filesystemError(let error):
            return "Something went wrong while accessing file system. Underlying error: \(error)"
        case .invalidIndexStore:
            return "Failed to read from index store. Make sure your project have been built."
        case .invalidLibIndexStore(let path, let error):
            return "Something is wrong with the libIndexStore library at \(path). "
                + "Underlying error: \(error)"
        }
    }
}
