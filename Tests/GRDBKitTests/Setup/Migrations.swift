//
//  Migrate.swift
//  GRDBKitTests
//
//  Created by Taylor McIntyre on 2019-03-26.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation
import GRDB
import GRDBKit

struct Migration1: Migration {
    static let migrationIdentifier = "Migration123"
    static func register(on migrator: inout DatabaseMigrator) throws {
        migrator.registerMigrationWithDeferredForeignKeyCheck(migrationIdentifier) { db in
            try db.create(table: "table1") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("age", .integer)
            }
        }
    }
}

struct Migration2: Migration {
    static func register(on migrator: inout DatabaseMigrator) throws {
        migrator.registerMigrationWithDeferredForeignKeyCheck(migrationIdentifier) { db in
            try db.create(table: "table2") { t in
                t.column("id", .integer).primaryKey()
                t.column("name", .text).notNull()
                t.column("active", .boolean).notNull()
            }
        }
    }
}

struct Migration3: Migration {
    static var migrationIdentifier: String { Schema1.m3.rawValue }
    static func register(on migrator: inout DatabaseMigrator) throws {
        migrator.registerMigrationWithDeferredForeignKeyCheck(migrationIdentifier) { db in
            try db.create(table: "table3") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("table2Id", .text).notNull().references("table2")
            }
        }
    }
}
