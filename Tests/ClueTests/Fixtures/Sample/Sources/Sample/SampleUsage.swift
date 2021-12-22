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
}
