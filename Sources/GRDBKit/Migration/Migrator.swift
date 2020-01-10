//
//  File.swift
//  
//
//  Created by Taylor McIntyre on 2020-01-10.
//

import Foundation
import GRDB

extension DatabaseWriter {
    public func migrateTo<T: MigrationVersion>(version: T) throws {
        var migrator = DatabaseMigrator()
        
        for migration in version.migrations {
            try migration.migrationType.register(on: &migrator)
        }
        
        try migrator.migrate(self, upTo: version.migrationType.migrationIdentifier)
    }
    
    public func migrate<T: MigrationVersion>(_ versioner: T.Type) throws where T: CaseIterable {
        var migrator = DatabaseMigrator()
        
        for migration in versioner.allCases {
            try migration.migrationType.register(on: &migrator)
        }
        
        try migrator.migrate(self)
    }
}
