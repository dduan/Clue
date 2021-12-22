@testable import Clue
import XCTest
import IndexStoreDB

final class ClueTests: XCTestCase {
    override class func setUp() {
        try! SampleProject.prepareFixture()
    }

    func verifyQuery(usr: USRQuery, reference: ReferenceQuery,
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
                reference: reference
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

    func verifySimpleQuery(symbolName: String, role: SymbolRole? = nil, negativeRole: SymbolRole = [],
                          expectedPaths: [(SampleProject.File, UInt, UInt)],
                          file: StaticString = #file, line: UInt = #line) throws
    {
        try self.verifyQuery(
            usr: .init(symbol: symbolName, module: nil, symbolKind: nil),
            reference: role.map { ReferenceQuery(usrs: [], role: $0, negativeRole: negativeRole) } ?? .empty,
            expectedPaths: expectedPaths,
            file: file,
            line: line
        )
    }

    func testSimpleGlobalVariable() throws {
        try verifySimpleQuery(
            symbolName: "publicGlobalVariable",
            expectedPaths: [
                (.sample, 6, 12),
                (.sampleUsage, 3, 11),
                (.sampleCLI, 3, 7)
            ]
        )
    }

    func testStructUsage() throws {
        try verifySimpleQuery(
            symbolName: "SampleStruct",
            expectedPaths: [
                (.sample, 1, 15),
                (.sampleUsage, 2, 24),
                (.sampleCLI, 4, 20),
            ]
        )
    }

    func testEnumUsage() throws {
        try verifySimpleQuery(
            symbolName: "SampleEnum",
            expectedPaths: [
                (.sample, 8, 13),
                (.sampleUsage, 7, 21),
                (.sampleCLI, 7, 14)
            ]
        )
    }

    func testClassAll() throws {
        try verifySimpleQuery(
            symbolName: "BaseClass",
            expectedPaths: [
                (.sample, 13, 12),
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
            role: [.baseOf],
            expectedPaths: [
                (.sampleUsage, 11, 27),
                (.sampleCLI, 10, 28),
            ]
        )
    }

    func testClassInstantiation() throws {
        try verifySimpleQuery(
            symbolName: "BaseClass",
            role: .reference,
            negativeRole: .baseOf,
            expectedPaths: [
                (.sampleUsage, 14, 11),
                (.sampleCLI, 9, 7),
            ]
        )
    }

    func testEnumCase() throws {
        try verifySimpleQuery(
            symbolName: "two",
            expectedPaths: [
                (.sample, 10, 10),
                (.sampleCLI, 7, 28),
            ]
        )
    }

    func testPublicFunction() throws {
        try verifySimpleQuery(
            symbolName: "publicGlobalFunction",
            expectedPaths: [
                (.sample, 17, 13),
                (.sampleUsage, 15, 5),
                (.sampleCLI, 11, 1),
            ]
        )
    }

    func testStructStaticMethod() throws {
        try verifySimpleQuery(
            symbolName: "structStaticMethod",
            expectedPaths: [
                (.sample, 21, 24),
                (.sampleUsage, 16, 23),
                (.sampleCLI, 12, 19),
            ]
        )
    }

    func testStructMethod() throws {
        try verifySimpleQuery(
            symbolName: "structMethod",
            expectedPaths: [
                (.sample, 22, 17),
                (.sampleUsage, 18, 13),
                (.sampleCLI, 14, 9),
            ]
        )
    }

    func testEnumStaticMethod() throws {
        try verifySimpleQuery(
            symbolName: "enumStaticMethod",
            expectedPaths: [
                (.sample, 27, 24),
                (.sampleUsage, 19, 21),
                (.sampleCLI, 15, 17),
            ]
        )
    }

    func testEnumMethod() throws {
        try verifySimpleQuery(
            symbolName: "enumMethod",
            expectedPaths: [
                (.sample, 28, 17),
                (.sampleUsage, 20, 27),
                (.sampleCLI, 16, 23),
            ]
        )
    }

    func testClassStaticMethod() throws {
        try verifySimpleQuery(
            symbolName: "classStaticMethod",
            expectedPaths: [
                (.sample, 33, 24),
                (.sampleUsage, 21, 22),
                (.sampleCLI, 17, 18),
            ]
        )
    }

    func testClassMethod() throws {
        try verifySimpleQuery(
            symbolName: "classMethod",
            expectedPaths: [
                (.sample, 34, 17),
                (.sampleUsage, 23, 12),
                (.sampleCLI, 19, 8),
            ]
        )
    }
}
