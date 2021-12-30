import IndexStoreDB

public enum ReferenceRole {
    public enum Preset {
        case instanceOnly
        case inheritanceOnly
    }

    case preset(Preset)
    case specific(role: SymbolRole = [], negativeRole: SymbolRole = [])
}

extension ReferenceRole {
    static var empty: Self { .specific() }
}

extension ReferenceRole {
    var positive: SymbolRole {
        switch self {
        case .preset(.instanceOnly):
            return .all
        case .preset(.inheritanceOnly):
            return .baseOf
        case .specific(let specificRoles, _):
            return specificRoles
        }
    }

    var negative: SymbolRole {
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
