import IndexStoreDB

extension IndexSymbolKind {
    init?(_ string: String) {
        let string = string.lowercased()
        if string == "unknown" { self = .unknown }
        else if string == "module" { self = .module }
        else if string == "namespace" { self = .namespace }
        else if string == "namespacealias" { self = .namespaceAlias }
        else if string == "macro" { self = .macro }
        else if string == "enum" { self = .enum }
        else if string == "struct" { self = .struct }
        else if string == "class" { self = .class }
        else if string == "protocol" { self = .protocol }
        else if string == "extension" { self = .extension }
        else if string == "union" { self = .union }
        else if string == "typealias" { self = .typealias }
        else if string == "function" { self = .function }
        else if string == "variable" { self = .variable }
        else if string == "field" { self = .field }
        else if string == "enumconstant" { self = .enumConstant }
        else if string == "instancemethod" { self = .instanceMethod }
        else if string == "classmethod" { self = .classMethod }
        else if string == "staticmethod" { self = .staticMethod }
        else if string == "instanceproperty" { self = .instanceProperty }
        else if string == "classproperty" { self = .classProperty }
        else if string == "staticproperty" { self = .staticProperty }
        else if string == "constructor" { self = .constructor }
        else if string == "destructor" { self = .destructor }
        else if string == "conversionfunction" { self = .conversionFunction }
        else if string == "parameter" { self = .parameter }
        else if string == "using" { self = .using }
        else if string == "commenttag" { self = .commentTag }
        else {
            return nil
        }
    }
}

extension IndexSymbolKind: CustomStringConvertible {
    public var description: String {
        switch self {
        case .module: return "module"
        case .namespace: return "namespace"
        case .namespaceAlias: return "namespaceAlias"
        case .macro: return "macro"
        case .enum: return "enum"
        case .struct: return "struct"
        case .class: return "class"
        case .protocol: return "protocol"
        case .extension: return "extension"
        case .union: return "union"
        case .typealias: return "typealias"
        case .function: return "function"
        case .variable: return "variable"
        case .field: return "field"
        case .enumConstant: return "enumConstant"
        case .instanceMethod: return "instanceMethod"
        case .classMethod: return "classMethod"
        case .staticMethod: return "staticMethod"
        case .instanceProperty: return "instanceProperty"
        case .classProperty: return "classProperty"
        case .staticProperty: return "staticProperty"
        case .constructor: return "constructor"
        case .destructor: return "destructor"
        case .conversionFunction: return "conversionFunction"
        case .parameter: return "parameter"
        case .using: return "using"
        case .commentTag: return "commentTag"
        default: return "unknown"
        }
    }
}
