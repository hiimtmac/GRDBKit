import XCTest
@testable import GRDBKit

class ModelTests: XCTestCase {
    
    func testOptionalTypes() throws {
        struct Opt: GRDBModel {
            var id: String?
            init(_ id: String? = nil) { self.id = id }
        }
        
        struct NonOpt: GRDBModel {
            var id: String
            init(_ id: String = "") { self.id = id }
        }
        
        XCTAssertThrowsError(try Opt().requireID())
        XCTAssertEqual(try Opt("hi").requireID(), "hi")
//        NonOpt().requireID() // doesnt compile
    }
    
    func testModelMatchesSchema() throws {
        try seed().read { db in
            XCTAssertEqual(try Table1.fetchCount(db), 5)
            XCTAssertEqual(try Table2.fetchCount(db), 5)
            XCTAssertEqual(try Table3.fetchCount(db), 5)
        }
    }
    
    static var allTests = [
        ("testOptionalTypes", testOptionalTypes),
        ("testModelMatchesSchema", testModelMatchesSchema)
    ]
}

