import XCTest
import GRDB
@testable import GRDBKit

class PivotTests: XCTestCase {
    
    func testIDEquatable() {
        let one = Table3(id: "1", name: "good", table2Id: 3)
        let two = Table3(id: "1", name: "bad", table2Id: 2)
        XCTAssertEqual(one, two)
    }
    
    func testModelMatchesSchema() throws {
        try seed().read { db in
            XCTAssertEqual(try Table1.fetchCount(db), 5)
            XCTAssertEqual(try Table2.fetchCount(db), 5)
            XCTAssertEqual(try Table3.fetchCount(db), 5)
        }
    }
    
    static var allTests = [
        ("testIDEquatable", testIDEquatable),
        ("testModelMatchesSchema", testModelMatchesSchema)
    ]
}
