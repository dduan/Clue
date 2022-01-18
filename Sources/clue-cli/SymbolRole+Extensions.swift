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

extension SymbolRole {
    static var allCases: [SymbolRole] {
        [
            .declaration,
            .definition,
            .reference,
            .read,
            .write,
            .call,
            .dynamic,
            .addressOf,
            .implicit,
            .childOf,
            .baseOf,
            .overrideOf,
            .receivedBy,
            .calledBy,
            .extendedBy,
            .accessorOf,
            .containedBy,
            .ibTypeOf,
            .specializationOf,
            .canonical,
        ]
    }
}

extension SymbolRole {
    private var singleRoleDescription: String {
        switch self.rawValue {
        case SymbolRole.declaration.rawValue:
            return "declaration"
        case SymbolRole.definition.rawValue:
            return "definition"
        case SymbolRole.reference.rawValue:
            return "reference"
        case SymbolRole.read.rawValue:
            return "read"
        case SymbolRole.write.rawValue:
            return "write"
        case SymbolRole.call.rawValue:
            return "call"
        case SymbolRole.dynamic.rawValue:
            return "dynamic"
        case SymbolRole.addressOf.rawValue:
            return "addressOf"
        case SymbolRole.implicit.rawValue:
            return "implicit"
        case SymbolRole.childOf.rawValue:
            return "childOf"
        case SymbolRole.baseOf.rawValue:
            return "baseOf"
        case SymbolRole.overrideOf.rawValue:
            return "overrideOf"
        case SymbolRole.receivedBy.rawValue:
            return "receivedBy"
        case SymbolRole.calledBy.rawValue:
            return "calledBy"
        case SymbolRole.extendedBy.rawValue:
            return "extendedBy"
        case SymbolRole.accessorOf.rawValue:
            return "accessorOf"
        case SymbolRole.containedBy.rawValue:
            return "containedBy"
        case SymbolRole.ibTypeOf.rawValue:
            return "ibTypeOf"
        case SymbolRole.specializationOf.rawValue:
            return "specializationOf"
        case SymbolRole.canonical.rawValue:
            return "canonical"
        default:
            return "unknown"
        }

    }

    var description: String {
        var result = [String]()
        for role in Self.allCases {
            if self.contains(role) {
                result.append(role.singleRoleDescription)
            }
        }
        return result.joined(separator: ", ")
    }
}
