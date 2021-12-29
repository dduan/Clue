import IndexStoreDB

extension SymbolRole {
    static func initialize(from roleStrings: [String]) -> (SymbolRole, [String]) {
        var roles: SymbolRole = []
        var problems = [String]()
        for roleString in roleStrings {
            if let role = self.init(roleString) {
                roles.insert(role)
            } else {
                problems.append(roleString)
            }
        }

        return (roles, problems)
    }

    init?(_ roleString: String) {
        let roleString = roleString.lowercased()
        if roleString == "declaration" { self = .declaration }
        else if roleString == "definition" { self = .definition }
        else if roleString == "reference" { self = .reference }
        else if roleString == "read" { self = .read }
        else if roleString == "write" { self = .write }
        else if roleString == "call" { self = .call }
        else if roleString == "dynamic" { self = .dynamic }
        else if roleString == "addressof" { self = .addressOf }
        else if roleString == "implicit" { self = .implicit }
        else if roleString == "childof" { self = .childOf }
        else if roleString == "baseof" { self = .baseOf }
        else if roleString == "overrideof" { self = .overrideOf }
        else if roleString == "receivedby" { self = .receivedBy }
        else if roleString == "calledby" { self = .calledBy }
        else if roleString == "extendedby" { self = .extendedBy }
        else if roleString == "accessorof" { self = .accessorOf }
        else if roleString == "containedby" { self = .containedBy }
        else if roleString == "ibtypeof" { self = .ibTypeOf }
        else if roleString == "specializationof" { self = .specializationOf }
        else if roleString == "canonical" { self = .canonical }
        else if roleString == "all" { self = .all }
        else {
            return nil
        }
    }
}
