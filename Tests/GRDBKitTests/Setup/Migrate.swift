//
//  Migrate.swift
//  GRDBKitTests
//
//  Created by Taylor McIntyre on 2019-03-26.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation
import GRDB

func prepareQueue() throws -> DatabaseQueue {
    let config = Configuration()
    let queue = DatabaseQueue(configuration: config)
    try createMigrate(queue: queue)
    return queue
}

func createMigrate(queue: DatabaseQueue) throws {
    var migrator = DatabaseMigrator()
    
    // 1st migration
    migrator.registerMigration("v1") { db in
        try TestInt.migrate(on: db)
        try TestString.migrate(on: db)
    }
    
    try migrator.migrate(queue)
}
