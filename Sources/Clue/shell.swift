import Foundation

func shell(_ command: String) throws -> Data {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/bin/bash")
    task.arguments = ["-c", command]
    let output = Pipe()
    task.standardOutput = output
    try task.run()
    task.waitUntilExit()
    return output.fileHandleForReading.readDataToEndOfFile()
}
