import XCTest

import GRDBKitTests

var tests = [XCTestCaseEntry]()
tests += ModelTests.allTests()
tests += MigrationTests.allTests()
XCTMain(tests)
