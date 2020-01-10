//
//  File.swift
//  
//
//  Created by Taylor McIntyre on 2020-01-10.
//

import Foundation

public protocol MigrationVersion {
    var previousMigration: Self? { get }
    var migrationType: Migration.Type { get }
}

extension MigrationVersion {
    var migrations: [Self] {
        return resolveMigrations().reversed()
    }
    
    func resolveMigrations() -> [Self] {
        if let prev = previousMigration {
            return [self] + prev.resolveMigrations()
        } else {
            return [self]
        }
    }
}
