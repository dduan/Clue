public struct ReferenceQuery {
    public let usr: ReferenceQuery.USR
    public let role: ReferenceQuery.Role

    public init(usr: ReferenceQuery.USR, role: ReferenceQuery.Role) {
        self.usr = usr
        self.role = role
    }
}
