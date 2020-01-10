import XCTest

import GRDBKitTests

var tests = [XCTestCaseEntry]()
tests += GRDBKitTests.allTests()
tests += TimestampTests.allTests()
XCTMain(tests)
