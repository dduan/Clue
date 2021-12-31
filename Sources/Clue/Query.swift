public struct Query {
    public let store: Query.Store
    public let usr: Query.USR
    public let role: Query.Role

    public init(store: Query.Store, usr: Query.USR, role: Query.Role) {
        self.store = store
        self.usr = usr
        self.role = role
    }
}
