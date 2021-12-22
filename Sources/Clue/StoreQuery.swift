import IndexStoreDB
import Pathos

public struct StoreQuery {
    let libIndexStore: String
    let location: Location

    public init(libIndexStore: String, location: StoreQuery.Location) {
        self.libIndexStore = libIndexStore
        self.location = location
    }
}

extension StoreQuery {
    /// Information that leads to a definitive file system location for an index store
    public enum Location {
        /// Name of an Xcode project.
        /// Will look for index store in `~/Library/Developer/Xcode/DerivedData/NAME.+/Index/DataStore`
        case xcode(projectName: String)

        /// Path to an SwiftPM project.
        /// Will look for index store in `PATH/.build/debug/index/store`
        case swiftpm(path: String)

        /// Precise path to an index store.
        case store(path: String)
    }
}

extension StoreQuery {
    public enum Failure: Error {
        case multipleXcodeCandidates([String])
        case missingStoreInXcode(at: String)
        case cannotFindXcode(at: String)
        case swiftpmDoesNotExist(at: String)
        case swiftpmWasNotBuiltInDebug(at: String)
        case filesystemError(Error)

        case invalidIndexStore
        case invalidLibIndexStore
    }
}

extension StoreQuery.Location {
    func resolveIndexStorePath() throws -> String {
        switch self {
        case .store(path: let path):
            return path
        case .xcode(projectName: let name):
            do {
                let potentialCandiates = try Path
                    .home()
                    .joined(with: "Library", "Developer", "Xcode", "DerivedData", "\(name)*")
                    .glob()
                if potentialCandiates.count < 1 {
                    throw StoreQuery.Failure.cannotFindXcode(at: name)
                } else if potentialCandiates.count > 1 {
                    throw StoreQuery.Failure.multipleXcodeCandidates(potentialCandiates.map { $0.description })
                }

                return potentialCandiates[0].description

            } catch let error {
                throw StoreQuery.Failure.filesystemError(error)
            }
        case .swiftpm(path: let pathString):
            let project = Path(pathString)
            guard project.exists(followSymlink: true) else {
                throw StoreQuery.Failure.swiftpmDoesNotExist(at: pathString)
            }

            let store = project.joined(with: ".build", "debug", "index", "store")
            guard store.exists(followSymlink: true) else {
                throw StoreQuery.Failure.swiftpmWasNotBuiltInDebug(at: store.description)
            }

            return store.description
        }
    }

}
