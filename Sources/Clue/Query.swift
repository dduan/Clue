public struct Query {
    public let usr: Query.USR
    public let role: Query.Role

    public init(usr: Query.USR, role: Query.Role) {
        self.usr = usr
        self.role = role
    }
}
