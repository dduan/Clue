public enum StoreInitializationError: Error {
    case multipleXcodeCandidates([String])
    case missingStoreInXcode(at: String)
    case cannotFindXcode(at: String)
    case swiftpmDoesNotExist(at: String)
    case swiftpmWasNotBuiltInDebug(at: String)
    case filesystemError(Error)

    case invalidIndexStore
    case invalidLibIndexStore(Error)
}
