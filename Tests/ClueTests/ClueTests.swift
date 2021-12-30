@testable import Clue
import XCTest
import IndexStoreDB

final class ClueTests: XCTestCase {
    override class func setUp() {
        try! SampleProject.prepareFixture()
    }

    func verifyQuery(usr: USRQuery, role: ReferenceRole,
                     expectedDefinition: (SampleProject.File, UInt, UInt),
                     expectedPaths: [(SampleProject.File, UInt, UInt)],
                     file: StaticString = #file, line: UInt = #line) throws
    {
        let result = try ClueEngine.execute(
            .init(
                store: .init(
                    libIndexStore: libIndexStore,
                    location: .swiftpm(path: "\(SampleProject.samplePath)")
                ),
                usr: usr,
                role: role
            )
        )
        result.occurrences.enumerated().forEach { (i, o) in
            print(i, o.location, o.roles)
        }
        XCTAssertEqual(
            Set(result.occurrences.map { $0.locationString }),
            Set(expectedPaths.map { "\($0.path):\($1):\($2)" }),
            file: file,
            line: line
        )
    }

    func verifySimpleQuery(symbolName: String, role: ReferenceRole = .empty,
                           expectedDefinition: (SampleProject.File, UInt, UInt),
                           expectedPaths: [(SampleProject.File, UInt, UInt)],
                           file: StaticString = #file, line: UInt = #line) throws
    {
        try self.verifyQuery(
            usr: .query(symbol: symbolName, isSystem: false),
            role: role,
            expectedDefinition: expectedDefinition,
            expectedPaths: expectedPaths,
            file: file,
            line: line
        )
    }

    func testSimpleGlobalVariable() throws {
        try verifySimpleQuery(
            symbolName: "publicGlobalVariable",
            expectedDefinition: (.sample, 6, 12),
            expectedPaths: [
                (.sampleUsage, 3, 11),
                (.sampleCLI, 3, 7)
            ]
        )
    }

    func testStructUsage() throws {
        try verifySimpleQuery(
            symbolName: "SampleStruct",
            expectedDefinition: (.sample, 1, 15),
            expectedPaths: [
                (.sampleUsage, 2, 24),
                (.sampleCLI, 4, 20),
            ]
        )
    }

    func testEnumUsage() throws {
        try verifySimpleQuery(
            symbolName: "SampleEnum",
            expectedDefinition: (.sample, 8, 13),
            expectedPaths: [
                (.sampleUsage, 7, 21),
                (.sampleCLI, 7, 14)
            ]
        )
    }

    func testClassAll() throws {
        try verifySimpleQuery(
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
        try verifySimpleQuery(
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
        try verifySimpleQuery(
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
        try verifySimpleQuery(
            symbolName: "two",
            expectedDefinition: (.sample, 10, 10),
            expectedPaths: [
                (.sampleCLI, 7, 28),
            ]
        )
    }

    func testPublicFunction() throws {
        try verifySimpleQuery(
            symbolName: "publicGlobalFunction",
            expectedDefinition: (.sample, 17, 13),
            expectedPaths: [
                (.sampleUsage, 15, 5),
                (.sampleCLI, 11, 1),
            ]
        )
    }

    func testStructStaticMethod() throws {
        try verifySimpleQuery(
            symbolName: "structStaticMethod",
            expectedDefinition: (.sample, 21, 24),
            expectedPaths: [
                (.sampleUsage, 16, 23),
                (.sampleCLI, 12, 19),
            ]
        )
    }

    func testStructMethod() throws {
        try verifySimpleQuery(
            symbolName: "structMethod",
            expectedDefinition: (.sample, 22, 17),
            expectedPaths: [
                (.sampleUsage, 18, 13),
                (.sampleCLI, 14, 9),
            ]
        )
    }

    func testEnumStaticMethod() throws {
        try verifySimpleQuery(
            symbolName: "enumStaticMethod",
            expectedDefinition: (.sample, 27, 24),
            expectedPaths: [
                (.sampleUsage, 19, 21),
                (.sampleCLI, 15, 17),
            ]
        )
    }

    func testEnumMethod() throws {
        try verifySimpleQuery(
            symbolName: "enumMethod",
            expectedDefinition: (.sample, 28, 17),
            expectedPaths: [
                (.sampleUsage, 20, 27),
                (.sampleCLI, 16, 23),
            ]
        )
    }

    func testClassStaticMethod() throws {
        try verifySimpleQuery(
            symbolName: "classStaticMethod",
            expectedDefinition: (.sample, 33, 24),
            expectedPaths: [
                (.sampleUsage, 21, 22),
                (.sampleCLI, 17, 18),
            ]
        )
    }

    func testClassMethod() throws {
        try verifySimpleQuery(
            symbolName: "classMethod",
            expectedDefinition: (.sample, 34, 17),
            expectedPaths: [
                (.sampleUsage, 23, 12),
                (.sampleCLI, 19, 8),
            ]
        )
    }

    func testProtocolReferenceAll() throws {
        try verifySimpleQuery(
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
        try verifySimpleQuery(
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
        try verifySimpleQuery(
            symbolName: "AProtocol",
            role: .preset(.instanceOnly),
            expectedDefinition: (.sample, 37, 17),
            expectedPaths: [
                (.sampleUsage, 24, 24),
                (.sampleCLI, 23, 20),
            ]
        )
    }
}
