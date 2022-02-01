import IndexStoreDB
import Pathos
import Foundation

/// Information that leads to a definitive file system location for an index store
public enum StoreLocation {
    /// Name of an Xcode project.
    /// Will look for index store in `~/Library/Developer/Xcode/DerivedData/NAME.+/Index/DataStore`
    case inferFromXcodeProject(atPath: String)

    /// Path to an SwiftPM project.
    /// Will look for index store in `PATH/.build/debug/index/store`
    case inferFromSwiftPMProject(atPath: String)

    /// Precise path to an index store.
    case path(String)
}

extension StoreLocation {
    func resolveIndexStorePath() throws -> String {
        switch self {
        case .path(let path):
            return path
        case .inferFromXcodeProject(let xcodeFile):
            return try self.inferFromXcodeFile(file: xcodeFile)
        case .inferFromSwiftPMProject(atPath: let pathString):
            let project = Path(pathString)
            guard project.exists(followSymlink: true) else {
                throw StoreInitializationError.swiftpmDoesNotExist(at: pathString)
            }

            let store = project.joined(with: ".build", "debug", "index", "store")
            guard store.exists(followSymlink: true), let absolutePath = try? store.absolute().normal else {
                throw StoreInitializationError.swiftpmWasNotBuiltInDebug(at: store.description)
            }

            return absolutePath.description
        }
    }

    func inferFromXcodeFile(file: String) throws -> String {
        if file.hasSuffix(".xcworkspace") {
            return try inferFromXcodeWorkspace(file: file)
        } else if file.hasSuffix(".xcodeproj") {
            return try inferFromXcodeProject(file: file)
        } else {
            throw StoreInitializationError.invalidXcodeInput
        }
    }

    func inferFromXcodeWorkspace(file: String) throws -> String {
        let schemeListOutput = String(data: try shell("xcodebuild -workspace \(file) -list"), encoding: .utf8)
        guard let lastLine = schemeListOutput?
                .split(separator: "\n", omittingEmptySubsequences: true)
                .reversed()
                .first
        else {
            throw StoreInitializationError.couldNotFindSchemeInXcodeWorkspace(file)
        }

        let scheme = lastLine.dropFirst(8)
        let settingsOutputData = try shell("xcodebuild -workspace \(file) -scheme '\(scheme)' -showBuildSettings")

        return try storePath(file: file, fromSettingsOutput: settingsOutputData)
    }

    func inferFromXcodeProject(file: String) throws -> String {
        let settingsOutputData = try shell("xcodebuild -project \(file) -showBuildSettings")
        return try storePath(file: file, fromSettingsOutput: settingsOutputData)
    }

    func storePath(file: String, fromSettingsOutput settingsOutputData: Data) throws -> String {
        let settingsOutput = String(data: settingsOutputData, encoding: .utf8)
        guard let buildDirParts = settingsOutput?
                .split(separator: "\n")
                .first { $0.starts(with: "    BUILD_DIR =") }?
                .split(separator: " ", omittingEmptySubsequences: true),
            buildDirParts.count == 3,
            case let buildDir = buildDirParts[2],
            buildDir.hasPrefix("/") else
        {
            throw StoreInitializationError.couldNotFindIndexStorePathFromXcode(file)
        }

        return buildDir + "/../../Index/DataStore"
    }
}
