//
//  GRDBKitTests.swift
//  GRDBKitTests
//
//  Created by Taylor McIntyre on 2019-03-13.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
@testable import GRDBKit

class GRDBKitTests: XCTestCase {
    
    var queue: DatabaseQueue!
    
    override func setUp() {
        super.setUp()
        
        queue = try! prepareQueue()
    }
    
    func testPrimaryKeyAutoInserts() throws {
        try queue.write { db in
            var testInt1 = TestInt(name: "taylor")
            try testInt1.insert(timestamping: db)
            
            XCTAssertEqual(testInt1.id, 1)
            
            var testInt2 = TestInt(name: "taylor")
            try testInt2.insert(timestamping: db)
            
            XCTAssertEqual(testInt2.id, 2)
            
            let one = try TestInt
                .order(TestInt.Columns.id)
                .fetchOne(db)
            
            let two = try TestInt
                .order(TestInt.Columns.id.desc)
                .fetchOne(db)
            
            XCTAssertEqual(one?.id, 1)
            XCTAssertEqual(two?.id, 2)
        }
    }
    
    static var allTests = [
        ("testPrimaryKeyAutoInserts", testPrimaryKeyAutoInserts)
    ]
}
