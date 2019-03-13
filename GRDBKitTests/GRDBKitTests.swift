//
//  GRDBKitTests.swift
//  GRDBKitTests
//
//  Created by Taylor McIntyre on 2019-03-13.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import XCTest
import GRDB
@testable import GRDBKit

class GRDBKitTests: XCTestCase {
    
    var queue: DatabaseQueue!
    var date: Date!
    
    override func setUp() {
        super.setUp()
        
        let config = Configuration()
        queue = DatabaseQueue(configuration: config)
        try! createMigrate(queue: queue)
        
        date = DateComponents(calendar: .current, year: 2018, month: 1, day: 1).date!
    }
    
    func testPrimaryKeyAutoInserts() throws {
        try queue.write { db in
            var testInt = TestInt(name: "taylor")
            try testInt.insert(timestamping: db, date: date)
            XCTAssertNotNil(testInt.id)
            
            var testString = TestString(name: "taylor")
            try testString.insert(timestamping: db, date: date)
            XCTAssertNotNil(testString.id)
            
            let fetchInt = try TestInt.fetchOne(db)!
            XCTAssertEqual(fetchInt.createdAt, date)
        }
    }
}

func createMigrate(queue: DatabaseQueue) throws {
    var migrator = DatabaseMigrator()
    
    // 1st migration
    migrator.registerMigration("v1") { db in
        try db.create(table: "testint") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("name", .text).notNull()
            t.column("createdAt", .datetime)
            t.column("modifiedAt", .datetime)
        }
        try db.create(table: "teststring") { t in
            t.column("id", .text).primaryKey()
            t.column("name", .text).notNull()
            t.column("createdAt", .datetime).notNull()
            t.column("modifiedAt", .datetime).notNull()
        }
    }
    
    try migrator.migrate(queue)
}

final class TestInt: GRDBIntModel {
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.modifiedAt }
    
    var id: Int?
    var name: String
    var createdAt: Date?
    var modifiedAt: Date?
    
    init(id: Int? = nil, name: String, createdAt: Date? = nil, modifiedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

extension TestInt: FetchableRecord, TableRecord, PersistableRecord {
    enum Columns: String, ColumnExpression {
        case id
        case name
        case createdAt
        case modifiedAt
    }
    
    convenience init(row: Row) {
        let id: Int? = row[Columns.id]
        let name: String = row[Columns.name]
        let createdAt: Date = row[Columns.createdAt]
        let modifiedAt: Date = row[Columns.modifiedAt]
        self.init(id: id, name: name, createdAt: createdAt, modifiedAt: modifiedAt)
    }
    
    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.createdAt] = createdAt
        container[Columns.modifiedAt] = modifiedAt
    }
    
    func didInsert(with rowID: Int64, for column: String?) {
        id = Int(rowID)
    }
}

final class TestString: GRDBStringModel {
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.modifiedAt }
    
    var id: String?
    var name: String
    var createdAt: Date?
    var modifiedAt: Date?
    
    init(id: String? = UUID().uuidString, name: String, createdAt: Date? = nil, modifiedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

extension TestString: FetchableRecord, TableRecord, PersistableRecord {
    enum Columns: String, ColumnExpression {
        case id
        case name
        case createdAt
        case modifiedAt
    }
    
    convenience init(row: Row) {
        let id: String? = row[Columns.id]
        let name: String = row[Columns.name]
        let createdAt: Date = row[Columns.createdAt]
        let modifiedAt: Date = row[Columns.modifiedAt]
        self.init(id: id, name: name, createdAt: createdAt, modifiedAt: modifiedAt)
    }
    
    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.createdAt] = createdAt
        container[Columns.modifiedAt] = modifiedAt
    }
}

