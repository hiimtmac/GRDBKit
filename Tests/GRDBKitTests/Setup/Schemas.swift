//
//  File.swift
//  
//
//  Created by Taylor McIntyre on 2020-01-10.
//

import Foundation
import GRDBKit

enum Schema1: String, MigrationVersion, Equatable {
    case m1
    case m2
    case m3
    
    var migrationType: Migration.Type {
        switch self {
        case .m1: return Migration1.self
        case .m2: return Migration2.self
        case .m3: return Migration3.self
        }
    }
    
    var previousMigration: Schema1? {
        switch self {
        case .m1: return nil
        case .m2: return .m1
        case .m3: return .m2
        }
    }
}

enum Schema2: String, MigrationVersion, CaseIterable, Equatable {
    case m1
    case m2
    case m3 = "mig3"
    
    var migrationType: Migration.Type {
        switch self {
        case .m1: return Migration1.self
        case .m2: return Migration2.self
        case .m3: return Migration3.self
        }
    }
    
    var previousMigration: Schema2? {
        switch self {
        case .m1: return nil
        case .m2: return .m1
        case .m3: return .m2
        }
    }
}
