import Foundation
import Pathos
import XCTest
import Clue

func bash(_ command: String, caller: String) throws {
    print("[\(caller)] Running command `\(command)`")
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/bin/bash")
    task.arguments = ["-c", command]
    try task.run()
    task.waitUntilExit()
}

let libIndexStore = try! defaultPathToLibIndexStore()

enum SampleProject {
    static let samplePath = try! Path("\(#filePath)")
        .parent
        .joined(with: "Fixtures", "Sample")
        .absolute()

    static func prepareFixture(caller: String = #fileID) throws {
        print("[\(caller)] Preparing fixture …")
        try self.samplePath
            .asWorkingDirectory {
                try bash("swift package clean", caller: caller)
                try bash("swift build", caller: caller)
            }
    }

}

extension SampleProject {
    enum File {
        case sample
        case sampleUsage
        case sampleCLI

        private func samplePath(_ parts: [String]) -> String {
            "\(SampleProject.samplePath.joined(with: parts))"
        }

        var path: String {
            switch self {
            case .sample:
                return samplePath(["Sources", "Sample", "Sample.swift"])
            case .sampleUsage:
                return samplePath(["Sources", "Sample", "SampleUsage.swift"])
            case .sampleCLI:
                return samplePath(["Sources", "sample-cli", "main.swift"])
            }
        }
    }
}
