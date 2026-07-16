//
//  File.swift
//  
//
//  Created by Taylor McIntyre on 2020-01-10.
//

import XCTest
@testable import GRDBKit

class MigrationTests: XCTestCase {
    
    func testMigrationResolvesPrevious() {
        XCTAssertEqual(Schema1.m3.migrations, [.m1, .m2, .m3])
        XCTAssertEqual(Schema1.m2.migrations, [.m1, .m2])
        XCTAssertEqual(Schema1.m1.migrations, [.m1])
        
        XCTAssertEqual(Schema2.m3.migrations, [.m1, .m2, .m3])
        XCTAssertEqual(Schema2.m2.migrations, [.m1, .m2])
        XCTAssertEqual(Schema2.m1.migrations, [.m1])
    }
    
    func testMigrateTo() throws {
        let queue1 = DatabaseQueue()
        try queue1.migrateTo(version: Schema1.m3)
        try queue1.read { db in
            XCTAssert(try db.tableExists("table1"))
            XCTAssert(try db.tableExists("table2"))
            XCTAssert(try db.tableExists("table3"))
        }
        
        let queue2 = DatabaseQueue()
        try queue2.migrateTo(version: Schema1.m2)
        try queue2.read { db in
            XCTAssert(try db.tableExists("table1"))
            XCTAssert(try db.tableExists("table2"))
            XCTAssert(try !db.tableExists("table3"))
        }

        let queue3 = DatabaseQueue()
        try queue3.migrateTo(version: Schema1.m1)
        try queue3.read { db in
            XCTAssert(try db.tableExists("table1"))
            XCTAssert(try !db.tableExists("table2"))
            XCTAssert(try !db.tableExists("table3"))
        }
    }
    
    func testMigrateAll() throws {
        let queue1 = DatabaseQueue()
        try queue1.migrate(Schema2.self)
        try queue1.read { db in
            XCTAssert(try db.tableExists("table1"))
            XCTAssert(try db.tableExists("table2"))
            XCTAssert(try db.tableExists("table3"))
        }
        
        let queue2 = DatabaseQueue()
        try queue2.migrateTo(version: Schema2.m2)
        try queue2.read { db in
            XCTAssert(try db.tableExists("table1"))
            XCTAssert(try db.tableExists("table2"))
            XCTAssert(try !db.tableExists("table3"))
        }
        
        let queue3 = DatabaseQueue()
        try queue3.migrateTo(version: Schema2.m3)
        try queue3.read { db in
            XCTAssert(try db.tableExists("table1"))
            XCTAssert(try db.tableExists("table2"))
            XCTAssert(try db.tableExists("table3"))
        }
    }
    
    static var allTests = [
        ("testMigrationResolvesPrevious", testMigrationResolvesPrevious),
        ("testMigrateTo", testMigrateTo),
        ("testMigrateAll", testMigrateAll)
    ]
}

