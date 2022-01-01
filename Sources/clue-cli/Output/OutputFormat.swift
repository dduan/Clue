import ArgumentParser

enum OutputFormat: String, RawRepresentable {
    case automatic
    case readable
    case colored
    case csv
    case json
}
