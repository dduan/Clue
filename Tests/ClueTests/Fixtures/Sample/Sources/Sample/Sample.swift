public struct SampleStruct {
    public var x = 42
    public init() {}
}

public let publicGlobalVariable = 42

public enum SampleEnum {
    case one
    case two(name: String)
}

open class BaseClass {
    public init() {}
}

public func publicGlobalFunction() {}

public struct StructWithMethods {
    public init() {}
    public static func structStaticMethod() {}
    public func structMethod() {}
}

public enum EnumWithMethods {
    case three
    public static func enumStaticMethod() {}
    public func enumMethod() {}
}

public final class ClassWithMethods {
    public init() {}
    public static func classStaticMethod() {}
    public func classMethod() {}
}

public protocol AProtocol {
    func protocolMethod()
}

public final class ClassWithPropreties {
    public static var simpleStaticClassProperty: String = ""
    public var simpleClassProperty: String = ""
    public init () {}
    public var customClassProperty: String {
        get { simpleClassProperty }
        set { simpleClassProperty = newValue }
    }
}
