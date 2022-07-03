import ArgumentParser

enum OutputFormat: String, RawRepresentable, CaseIterable {
    case automatic
    case readable
    case colored
    case csv
    case tsv
    case json
    case files
}
