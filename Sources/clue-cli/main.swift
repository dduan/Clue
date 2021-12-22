import Clue

let options = CLI.parseOrExit()

guard options.store != nil || options.xcode != nil || options.swiftpm != nil else {
    bail("Please provide value for one of --store, --xcode, or --swiftpm.")
}

func hello(_ namexxx: String) {
    print("hello \(namexxx)!")
}

do {
    let r = try Clue.ClueEngine.execute(
        .init(
            store: .init(libIndexStore: options.lib, location: .swiftpm(path: options.swiftpm ?? "")),
            usr: .init(symbol: options.symbol, module: nil, symbolKind: nil),
            reference: .init(usrs: [], role: [], negativeRole: [])
        )
    )

    r.occurrences.map { "\($0.location.path):\($0.location.line):\($0.location.utf8Column):\($0.symbol.kind)" }.forEach { print($0) }
    hello("world")
} catch let error {
    print(error)
}
