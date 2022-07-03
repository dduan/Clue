import Chalk
import Clue
import IndexStoreDB
import Pathos

extension Finding {
    func readableOutput(colored: Bool) -> String {
        var lines = [String]()
        var occurByFile = [String: [SymbolOccurrence]]()
        switch self.details {
        case .find(_, let definition, let occurrences):
            for occur in [definition] + occurrences {
                occurByFile[occur.location.path, default: []].append(occur)
            }

            for file in occurByFile.keys {
                let content = (try? Path(file).readUTF8String())?
                    .split(separator: "\n", omittingEmptySubsequences: false)
                    ?? []
                lines.append(colored ? "\(file, color: .magenta)" : file)
                for occur in occurByFile[file, default: []] {
                    let location = occur.location
                    let lineContent = content.count > location.line ? content[location.line - 1] : ""
                    if colored {
                        let prefix = lineContent.prefix(location.utf8Column - 1)
                        let nameToHighlight = definition.symbol.name.split(separator: "(")[0]
                        let highlight = lineContent
                            .dropFirst(location.utf8Column - 1)
                            .prefix(nameToHighlight.count)
                        let postfix = lineContent.dropFirst(location.utf8Column - 1 + nameToHighlight.count)
                        lines.append("\(location.line, color: .green):\(location.utf8Column):\(prefix)\(highlight, color: .red)\(postfix)")
                    } else {
                        lines.append("\(location.line):\(location.utf8Column):\(lineContent)")
                    }
                }

                lines.append("")
            }

            return lines.joined(separator: "\n")
        case .dump(_, let definitions):
            for occur in definitions {
                occurByFile[occur.location.path, default: []].append(occur)
            }
            for file in occurByFile.keys {
                lines.append(colored ? "\(file, color: .magenta)" : file)
                for definition in occurByFile[file, default: []] {
                    let location = definition.location
                    if colored {
                        lines.append("\(location.line, color: .green):\(location.utf8Column): \(definition.symbol.kind, style: .bold) \(definition.symbol.name, color: .red) \(definition.symbol.usr)")
                    } else {
                        lines.append("\(location.line):\(location.utf8Column): \(definition.symbol.kind) \(definition.symbol.name) \(definition.symbol.usr)")
                    }
                }

                lines.append("")
            }

            return lines.joined(separator: "\n")
        }
    }
}
