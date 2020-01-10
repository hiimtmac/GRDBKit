import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ModelTests.allTests),
        testCase(MigrationTests.allTests)
    ]
}
#endif
