@testable import Clue
import XCTest
import IndexStoreDB

final class ClueTests: XCTestCase {
    static var engine: ClueEngine!

    override class func setUp() {
        try! SampleProject.prepareFixture()
        self.engine = try! ClueEngine(
            libIndexStorePath: libIndexStore,
            storeLocation: .inferFromSwiftPMProject(atPath: "\(SampleProject.samplePath)")
        )
    }

    static func verifySimpleQuery(symbolName: String, role: ReferenceQuery.Role = .empty,
                                  expectedDefinition: (SampleProject.File, UInt, UInt),
                                  expectedPaths: [(SampleProject.File, UInt, UInt)],
                                  file: StaticString = #file, line: UInt = #line) throws
    {
        let result = try self.engine.execute(
            .find(
                .init(
                    usr: .query(symbol: symbolName, isSystem: false, strictSymbolLookup: false),
                    role: role
                )
            )
        )

        guard case Finding.Details.find(_, let definition, let occurrences) = result.details else {
            XCTFail("Expected references result")
            return
        }

        XCTAssertEqual(
            definition.locationString,
            "\(expectedDefinition.0.path):\(expectedDefinition.1):\(expectedDefinition.2)"
        )

        XCTAssertEqual(
            Set(occurrences.map { $0.locationString }),
            Set(expectedPaths.map { "\($0.path):\($1):\($2)" }),
            file: file,
            line: line
        )
    }

    func testSimpleGlobalVariable() throws {
        try Self.verifySimpleQuery(
            symbolName: "publicGlobalVariable",
            expectedDefinition: (.sample, 6, 12),
            expectedPaths: [
                (.sampleUsage, 3, 11),
                (.sampleCLI, 3, 7)
            ]
        )
    }

    func testStructUsage() throws {
        try Self.verifySimpleQuery(
            symbolName: "SampleStruct",
            expectedDefinition: (.sample, 1, 15),
            expectedPaths: [
                (.sampleUsage, 2, 24),
                (.sampleCLI, 4, 20),
            ]
        )
    }

    func testEnumUsage() throws {
        try Self.verifySimpleQuery(
            symbolName: "SampleEnum",
            expectedDefinition: (.sample, 8, 13),
            expectedPaths: [
                (.sampleUsage, 7, 21),
                (.sampleCLI, 7, 14)
            ]
        )
    }

    func testClassAll() throws {
        try Self.verifySimpleQuery(
            symbolName: "BaseClass",
            expectedDefinition: (.sample, 13, 12),
            expectedPaths: [
                (.sampleUsage, 14, 11),
                (.sampleUsage, 11, 27),
                (.sampleCLI, 9, 7),
                (.sampleCLI, 10, 28),
            ]
        )
    }

    func testClassInheritance() throws {
        try Self.verifySimpleQuery(
            symbolName: "BaseClass",
            role: .preset(.inheritanceOnly),
            expectedDefinition: (.sample, 13, 12),
            expectedPaths: [
                (.sampleUsage, 11, 27),
                (.sampleCLI, 10, 28),
            ]
        )
    }

    func testClassInstantiation() throws {
        try Self.verifySimpleQuery(
            symbolName: "BaseClass",
            role: .preset(.instanceOnly),
            expectedDefinition: (.sample, 13, 12),
            expectedPaths: [
                (.sampleUsage, 14, 11),
                (.sampleCLI, 9, 7),
            ]
        )
    }

    func testEnumCase() throws {
        try Self.verifySimpleQuery(
            symbolName: "two",
            expectedDefinition: (.sample, 10, 10),
            expectedPaths: [
                (.sampleCLI, 7, 28),
            ]
        )
    }

    func testPublicFunction() throws {
        try Self.verifySimpleQuery(
            symbolName: "publicGlobalFunction",
            expectedDefinition: (.sample, 17, 13),
            expectedPaths: [
                (.sampleUsage, 15, 5),
                (.sampleCLI, 11, 1),
            ]
        )
    }

    func testStructStaticMethod() throws {
        try Self.verifySimpleQuery(
            symbolName: "structStaticMethod",
            expectedDefinition: (.sample, 21, 24),
            expectedPaths: [
                (.sampleUsage, 16, 23),
                (.sampleCLI, 12, 19),
            ]
        )
    }

    func testStructMethod() throws {
        try Self.verifySimpleQuery(
            symbolName: "structMethod",
            expectedDefinition: (.sample, 22, 17),
            expectedPaths: [
                (.sampleUsage, 18, 13),
                (.sampleCLI, 14, 9),
            ]
        )
    }

    func testEnumStaticMethod() throws {
        try Self.verifySimpleQuery(
            symbolName: "enumStaticMethod",
            expectedDefinition: (.sample, 27, 24),
            expectedPaths: [
                (.sampleUsage, 19, 21),
                (.sampleCLI, 15, 17),
            ]
        )
    }

    func testEnumMethod() throws {
        try Self.verifySimpleQuery(
            symbolName: "enumMethod",
            expectedDefinition: (.sample, 28, 17),
            expectedPaths: [
                (.sampleUsage, 20, 27),
                (.sampleCLI, 16, 23),
            ]
        )
    }

    func testClassStaticMethod() throws {
        try Self.verifySimpleQuery(
            symbolName: "classStaticMethod",
            expectedDefinition: (.sample, 33, 24),
            expectedPaths: [
                (.sampleUsage, 21, 22),
                (.sampleCLI, 17, 18),
            ]
        )
    }

    func testClassMethod() throws {
        try Self.verifySimpleQuery(
            symbolName: "classMethod",
            expectedDefinition: (.sample, 34, 17),
            expectedPaths: [
                (.sampleUsage, 23, 12),
                (.sampleCLI, 19, 8),
            ]
        )
    }

    func testProtocolReferenceAll() throws {
        try Self.verifySimpleQuery(
            symbolName: "AProtocol",
            expectedDefinition: (.sample, 37, 17),
            expectedPaths: [
                (.sampleUsage, 24, 24),
                (.sampleUsage, 28, 37),
                (.sampleCLI, 20, 37),
                (.sampleCLI, 23, 20),
            ]
        )
    }

    func testProtocolConfirmation() throws {
        try Self.verifySimpleQuery(
            symbolName: "AProtocol",
            role: .preset(.inheritanceOnly),
            expectedDefinition: (.sample, 37, 17),
            expectedPaths: [
                (.sampleUsage, 28, 37),
                (.sampleCLI, 20, 37),
            ]
        )
    }

    func testProtocolReference() throws {
        try Self.verifySimpleQuery(
            symbolName: "AProtocol",
            role: .preset(.instanceOnly),
            expectedDefinition: (.sample, 37, 17),
            expectedPaths: [
                (.sampleUsage, 24, 24),
                (.sampleCLI, 23, 20),
            ]
        )
    }

    func testClassProperties() throws {
        try Self.verifySimpleQuery(
            symbolName: "simpleClassProperty",
            expectedDefinition: (.sample, 43, 16),
            expectedPaths: [
                (.sampleUsage, 34, 26),
                (.sampleUsage, 36, 20),
                (.sampleCLI, 27, 22),
                (.sampleCLI, 29, 16),
                (.sample, 46, 15),
                (.sample, 47, 15),
            ]
        )

    }

    func testStaticClassProperties() throws {
        try Self.verifySimpleQuery(
            symbolName: "simpleStaticClassProperty",
            expectedDefinition: (.sample, 42, 23),
            expectedPaths: [
                (.sampleUsage, 35, 31),
                (.sampleUsage, 37, 25),
                (.sampleCLI, 28, 27),
                (.sampleCLI, 30, 21),
            ]
        )
    }

    func testClassPropertiesWithGetterSetter() throws {
        try Self.verifySimpleQuery(
            symbolName: "customClassProperty",
            expectedDefinition: (.sample, 45, 16),
            expectedPaths: [
                (.sampleUsage, 38, 20),
                (.sampleUsage, 39, 26),
                (.sampleCLI, 31, 16),
                (.sampleCLI, 32, 22)
            ]
        )
    }
}
