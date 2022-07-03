import IndexStoreDB

extension IndexSymbolKind {
    public static var allCases: [IndexSymbolKind] {
        [
            .module,
            .namespace,
            .namespaceAlias,
            .macro,
            .enum,
            .struct,
            .class,
            .protocol,
            .extension,
            .union,
            .typealias,
            .function,
            .variable,
            .field,
            .enumConstant,
            .instanceMethod,
            .classMethod,
            .staticMethod,
            .instanceProperty,
            .classProperty,
            .staticProperty,
            .constructor,
            .destructor,
            .conversionFunction,
            .parameter,
            .using,
            .commentTag,
        ]
    }
}
