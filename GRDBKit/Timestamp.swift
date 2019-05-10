//
//  Timestamp.swift
//  GRDBKit
//
//  Created by Taylor McIntyre on 2019-02-06.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation
import GRDB

public typealias Timestamp = Date

public protocol GRDBTimestampModel: GRDBModel {
    // Timestamps
    typealias TimestampKey = WritableKeyPath<Self, Date?>
    static var createdAtKey: TimestampKey? { get }
    static var updatedAtKey: TimestampKey? { get }
}

extension GRDBTimestampModel {
    /// Default conformance
    public static var createdAtKey: TimestampKey? {
        return nil
    }
    
    /// Default conformance
    public static var updatedAtKey: TimestampKey? {
        return nil
    }
}

extension GRDBTimestampModel {
    /// Access the timestamp keyed by `createdAtKey`.
    public var modelCreatedAt: Date? {
        get {
            guard let createdAt = Self.createdAtKey else {
                return nil
            }
            return self[keyPath: createdAt]
        }
        set {
            guard let createdAt = Self.createdAtKey else {
                return
            }
            self[keyPath: createdAt] = newValue
        }
    }
    
    /// Access the timestamp keyed by `updatedAtKey`.
    public var modelUpdatedAt: Date? {
        get {
            guard let updatedAt = Self.updatedAtKey else {
                return nil
            }
            return self[keyPath: updatedAt]
        }
        set {
            guard let updatedAt = Self.updatedAtKey else {
                return
            }
            self[keyPath: updatedAt] = newValue
        }
    }
}

extension GRDBTimestampModel where Self: MutablePersistableRecord {
    public mutating func update(timestamping db: Database, date: Date = .init()) throws {
        modelUpdatedAt = date
        try update(db)
    }
    
    public mutating func insert(timestamping db: Database, date: Date = .init()) throws {
        modelCreatedAt = date
        modelUpdatedAt = date
        try insert(db)
    }
    
    public mutating func save(timestamping db: Database, date: Date = .init()) throws {
        do {
            try update(timestamping: db, date: date)
        } catch PersistenceError.recordNotFound {
            try insert(timestamping: db, date: date)
        }
    }
}
