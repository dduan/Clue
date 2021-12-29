import IndexStoreDB

public struct ReferenceQuery {
    public let usrs: [String]
    public let role: Role

    public init(usrs: [String], role: Role) {
        self.usrs = usrs
        self.role = role
    }
}

extension ReferenceQuery {
    public static let empty = ReferenceQuery(usrs: [], role: .specific(role: [], negativeRole: []))
}

extension ReferenceQuery {
    public enum RolePreset {
        case instanceOnly
        case inheritanceOnly
    }

    public enum Role {
        case preset(RolePreset)
        case specific(role: SymbolRole = [], negativeRole: SymbolRole = [])

        static var empty: Self { .specific() }
    }
}

extension ReferenceQuery {
    var positiveRole: SymbolRole {
        switch self.role {
        case .preset(.instanceOnly):
            return .all
        case .preset(.inheritanceOnly):
            return .baseOf
        case .specific(let specificRoles, _):
            return specificRoles
        }
    }

    var negativeRole: SymbolRole {
        switch self.role {
        case .preset(.instanceOnly):
            return .baseOf
        case .preset(.inheritanceOnly):
            return []
        case .specific(_, let specificRoles):
            return specificRoles
        }
    }
}
