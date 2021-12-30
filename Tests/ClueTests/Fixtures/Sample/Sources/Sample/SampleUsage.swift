func internalFunction() {
    let sampleStruct = SampleStruct()
    print(publicGlobalVariable)
    print(sampleStruct)
}

func printEnum(_ e: SampleEnum) {
    print(e)
}

final class DerivedClass: BaseClass {}

func f() {
    print(BaseClass())
    publicGlobalFunction()
    StructWithMethods.structStaticMethod()
    let aStruct = StructWithMethods()
    aStruct.structMethod()
    EnumWithMethods.enumStaticMethod()
    EnumWithMethods.three.enumMethod()
    ClassWithMethods.classStaticMethod()
    let aClass = ClassWithMethods()
    aClass.classMethod()
    let anExistential: AProtocol = StructConfirmingToAProtocol()
    print(anExistential)
}

struct StructConfirmingToAProtocol: AProtocol {
    func protocolMethod() {}
}

func g() {
    let classWithProps = ClassWithPropreties()
    print(classWithProps.simpleClassProperty)
    print(ClassWithPropreties.simpleStaticClassProperty)
    classWithProps.simpleClassProperty = "hello"
    ClassWithPropreties.simpleStaticClassProperty = "world"
    classWithProps.customClassProperty = "hello"
    print(classWithProps.customClassProperty)
}
