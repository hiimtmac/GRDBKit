//
//  File.swift
//  
//
//  Created by Taylor McIntyre on 2020-01-10.
//

import Foundation

public protocol Migration {
    static var migrationIdentifier: String { get }
    static func register(on migrator: inout DatabaseMigrator) throws
}

extension Migration {
    public static var migrationIdentifier: String {
        return "\(Self.self)"
    }
}
