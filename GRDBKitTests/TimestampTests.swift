//
//  TimestampTests.swift
//  GRDBKitTests
//
//  Created by Taylor McIntyre on 2019-03-26.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
@testable import GRDBKit

class TimestampTests: XCTestCase {

    var queue: DatabaseQueue!
    var date: Date!
    var update: Date!
    
    override func setUp() {
        super.setUp()
        
        queue = try! prepareQueue()
        date = DateComponents(calendar: .current, year: 2018, month: 1, day: 1).date!
        update = DateComponents(calendar: .current, year: 2019, month: 1, day: 1).date!
    }

    func testInsertTimestamp() throws {
        try queue.write { db in
            var int = TestInt(name: "taylor")
            try int.insert(timestamping: db, date: date)
            
            let testInt = try TestInt.fetchOne(db)
            XCTAssertEqual(testInt?.createdAt, date)
            XCTAssertEqual(testInt?.modifiedAt, date)
            
            var string = TestString(name: "taylor")
            try string.insert(timestamping: db, date: date)
            
            let testString = try TestString.fetchOne(db)
            XCTAssertEqual(testString?.createdAt, date)
            XCTAssertEqual(testString?.modifiedAt, date)
        }
    }
    
    func testUpdateTimestamp() throws {
        try queue.write { db in
            var int = TestInt(name: "taylor")
            try int.insert(timestamping: db, date: date)
            
            var testInt = try TestInt.fetchOne(db)
            testInt?.name = "new name"
            try testInt?.update(timestamping: db, date: update)
            
            let updateInt = try TestInt.fetchOne(db)
            XCTAssertEqual(updateInt?.createdAt, date)
            XCTAssertEqual(updateInt?.modifiedAt, update)
            
            var string = TestString(name: "taylor")
            try string.insert(timestamping: db, date: date)
            
            var testString = try TestString.fetchOne(db)
            testString?.name = "new name"
            try testString?.update(timestamping: db, date: update)
            
            let updateString = try TestString.fetchOne(db)
            XCTAssertEqual(updateString?.createdAt, date)
            XCTAssertEqual(updateString?.modifiedAt, update)
        }
    }
    
    func testSaveTimestamp() throws {
        try queue.write { db in
            var int = TestInt(name: "taylor")
            try int.save(timestamping: db, date: date)
            
            var testInt = try TestInt.fetchOne(db)
            XCTAssertEqual(testInt?.createdAt, date)
            XCTAssertEqual(testInt?.modifiedAt, date)
            
            testInt?.name = "new name"
            try testInt?.save(timestamping: db, date: update)
            
            let updateInt = try TestInt.fetchOne(db)
            XCTAssertEqual(updateInt?.createdAt, date)
            XCTAssertEqual(updateInt?.modifiedAt, update)
            
            var string = TestString(name: "taylor")
            try string.save(timestamping: db, date: date)
            
            var testString = try TestString.fetchOne(db)
            XCTAssertEqual(testString?.createdAt, date)
            XCTAssertEqual(testString?.modifiedAt, date)
            
            testString?.name = "new name"
            try testString?.save(timestamping: db, date: update)
            
            let updateString = try TestString.fetchOne(db)
            XCTAssertEqual(updateString?.createdAt, date)
            XCTAssertEqual(updateString?.modifiedAt, update)
        }
    }
}
