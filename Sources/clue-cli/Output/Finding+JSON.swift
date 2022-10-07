import Clue
import Foundation
import IndexStoreDB

extension Finding {
    func json() -> String {
        return (try? JSONEncoder().encode(self))
            .flatMap { String(data: $0, encoding: .utf8) }
            ?? "{}"
    }
}

extension Finding: Encodable {
    enum CodingKeys: String, CodingKey {
        case libIndexStore, storeLocation, query, definition, occurrences, definitions
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.libIndexStore, forKey: .libIndexStore)
        try values.encode(self.storeLocation, forKey: .storeLocation)
        switch self.details {
        case let .find(query, definition, occurrences):
            try values.encode(query, forKey: .query)
            try values.encode(definition, forKey: .definition)
            try values.encode(occurrences, forKey: .occurrences)
        case let .dump(query, definitions):
            try values.encode(query, forKey: .query)
            try values.encode(definitions, forKey: .definitions)
        }
    }
}

extension ModuleQuery: Encodable {
    enum CodingKeys: String, CodingKey {
        case moduleName, kinds
    }
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.name, forKey: .moduleName)
        try values.encode(self.kinds, forKey: .kinds)
    }
}

extension ReferenceQuery: Encodable {
    enum CodingKeys: String, CodingKey {
        case usr, role
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.usr, forKey: .usr)
        try values.encode(self.role, forKey: .role)
    }
}

extension ReferenceQuery.USR: Encodable {
    enum CodingKeys: String, CodingKey {
        case type, value, symbol, module, kind, isSystem, strictSymbolLookup
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .explict(let usrString, let isSystem):
            try values.encode("explict", forKey: .type)
            try values.encode(usrString, forKey: .value)
            try values.encode(isSystem, forKey: .isSystem)
        case let .query(symbol, module, kind, isSystem, strictSymbolLookup):
            try values.encode(symbol, forKey: .symbol)
            try values.encode(isSystem, forKey: .isSystem)
            try values.encode(strictSymbolLookup, forKey: .strictSymbolLookup)
            if let module = module {
                try values.encode(module, forKey: .module)
            }

            if let kind = kind {
                try values.encode("\(kind)", forKey: .kind)
            }
        }
    }
}

extension ReferenceQuery.Role: Encodable {
    enum CodingKeys: String, CodingKey {
        case include, exclude
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        if self.inclusive == .all {
            try values.encode("all", forKey: .include)
        } else {
            try values.encode("\(self.inclusive)", forKey: .include)
        }

        try values.encode("\(self.exclusive)", forKey: .exclude)
    }
}

extension IndexSymbolKind: Encodable {
    public func encode(to encoder: Encoder) throws {
        var value = encoder.singleValueContainer()
        try value.encode(self.description)
    }
}

extension Symbol: Encodable {
    enum CodingKeys: String, CodingKey {
        case usr, name, kind
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.usr, forKey: .usr)
        try values.encode(self.name, forKey: .name)
        try values.encode(self.kind.description, forKey: .kind)
    }
}

extension SymbolLocation: Encodable {
    enum CodingKeys: String, CodingKey {
        case path, moduleName, isSystem, line, utf8Column
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.path, forKey: .path)
        try values.encode(self.moduleName, forKey: .moduleName)
        try values.encode(self.isSystem, forKey: .isSystem)
        try values.encode(self.line, forKey: .line)
        try values.encode(self.utf8Column, forKey: .utf8Column)
    }
}

extension SymbolOccurrence: Encodable {
    enum CodingKeys: String, CodingKey {
        case symbol, location, roles
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.symbol, forKey: .symbol)
        try values.encode(self.location, forKey: .location)
        try values.encode(self.roles.description, forKey: .roles)
    }
}
