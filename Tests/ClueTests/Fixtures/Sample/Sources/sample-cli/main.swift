import Sample

print(publicGlobalVariable)
var sampleStruct = SampleStruct()
sampleStruct.x += 1
print(sampleStruct)
let theCase: SampleEnum = .two(name: "hello")
print(theCase)
print(BaseClass())
final class DerivedClass2: BaseClass {}
publicGlobalFunction()
StructWithMethods.structStaticMethod()
let aStruct = StructWithMethods()
aStruct.structMethod()
EnumWithMethods.enumStaticMethod()
EnumWithMethods.three.enumMethod()
ClassWithMethods.classStaticMethod()
let aClass = ClassWithMethods()
aClass.classMethod()
struct StructConfirmingToAProtocol: AProtocol {
    func protocolMethod() {}
}
let anExistential: AProtocol = StructConfirmingToAProtocol()
print(anExistential)

let classWithProps = ClassWithPropreties()
print(classWithProps.simpleClassProperty)
print(ClassWithPropreties.simpleStaticClassProperty)
classWithProps.simpleClassProperty = "hello"
ClassWithPropreties.simpleStaticClassProperty = "world"
classWithProps.customClassProperty = "hello"
print(classWithProps.customClassProperty)
