import IndexStoreDB

public struct ReferenceQuery {
    public let usrs: [String]
    public let role: SymbolRole
    public let negativeRole: SymbolRole

    public init(usrs: [String], role: SymbolRole, negativeRole: SymbolRole) {
        self.usrs = usrs
        self.role = role
        self.negativeRole = negativeRole
    }
}

extension ReferenceQuery {
    public static let empty = ReferenceQuery(usrs: [], role: [], negativeRole: [])
}
