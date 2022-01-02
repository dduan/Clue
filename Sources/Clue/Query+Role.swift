import IndexStoreDB

extension Query {
    public enum Role {
        public enum Preset {
            case instanceOnly
            case inheritanceOnly
        }

        case preset(Preset)
        case specific(role: SymbolRole = [], exclusiveRole: SymbolRole = [])
    }
}

extension Query.Role {
    static var empty: Self { .specific() }
}

extension Query.Role {
    public var inclusive: SymbolRole {
        switch self {
        case .preset(.instanceOnly):
            return .all
        case .preset(.inheritanceOnly):
            return .baseOf
        case .specific(let specificRoles, _):
            return specificRoles
        }
    }

    public var exclusive: SymbolRole {
        switch self {
        case .preset(.instanceOnly):
            return .baseOf
        case .preset(.inheritanceOnly):
            return []
        case .specific(_, let specificRoles):
            return specificRoles
        }
    }
}
