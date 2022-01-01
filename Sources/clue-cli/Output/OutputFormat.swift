import ArgumentParser

enum OutputFormat: String, RawRepresentable {
    case automatic
    case readable
    case csv
    case json
}
