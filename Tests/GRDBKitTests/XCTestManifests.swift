import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(GRDBKitTests.allTests),
        testCast(TimestampTests.allTests)
    ]
}
#endif
