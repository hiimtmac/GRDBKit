//
//  TestInt.swift
//  GRDBKitTests
//
//  Created by Taylor McIntyre on 2019-03-26.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation
import GRDBKit
import GRDB

final class TestInt: GRDBIntModel, GRDBTimestampModel {
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
    
    static func migrate(on db: Database) throws {
        try db.create(table: "testint") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("name", .text).notNull()
            t.column("createdAt", .datetime)
            t.column("modifiedAt", .datetime)
        }
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
