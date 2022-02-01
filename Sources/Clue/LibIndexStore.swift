import Foundation
import Pathos

public func defaultPathToLibIndexStore() throws -> String {
    let outputData = try shell("swift -print-target-info")
    let json = try JSONSerialization.jsonObject(with: outputData)
    let pathToSwift = ((json as! [String: Any])["paths"] as! [String: Any])["runtimeResourcePath"] as! String
#if os(macOS)
    return "\(Path(pathToSwift).parent.joined(with: "libIndexStore.dylib"))"
#else
    return "\(Path(pathToSwift).parent.joined(with: "libIndexStore.so"))"
#endif
}
