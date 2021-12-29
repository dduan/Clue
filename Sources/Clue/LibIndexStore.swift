import Foundation
import Pathos

public func defaultPathToLibIndexStore() throws -> String {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/bin/bash")
    task.arguments = ["-c", "swift -print-target-info"]
    let output = Pipe()
    task.standardOutput = output
    try task.run()
    task.waitUntilExit()
    let outputData = output.fileHandleForReading.readDataToEndOfFile()
    let json = try JSONSerialization.jsonObject(with: outputData)
    let pathToSwift = ((json as! [String: Any])["paths"] as! [String: Any])["runtimeResourcePath"] as! String
    return "\(Path(pathToSwift).parent.joined(with: "libIndexStore.so"))"
}
