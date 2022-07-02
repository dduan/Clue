import IndexStoreDB

extension ReferenceQuery {
    public enum Role {
        public enum Preset {
            case instanceOnly
            case inheritanceOnly
        }

        case preset(Preset)
        case specific(role: SymbolRole = [], exclusiveRole: SymbolRole = [])
    }
}

extension ReferenceQuery.Role {
    static var empty: Self { .specific() }
}

extension ReferenceQuery.Role {
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
