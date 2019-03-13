//
//  Model.swift
//  GRDBKit
//
//  Created by Taylor McIntyre on 2019-01-07.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation
import GRDB

public protocol GRDBModel {
    // ID
    associatedtype ID = GRDBKit.ID
    typealias IDKey = WritableKeyPath<Self, ID?>
    static var idKey: IDKey { get }
    
    // Timestamps
    typealias TimestampKey = WritableKeyPath<Self, Date?>
    static var createdAtKey: TimestampKey? { get }
    static var updatedAtKey: TimestampKey? { get }
}

extension GRDBModel {
    /// See `Model`.
    public static var createdAtKey: TimestampKey? {
        return nil
    }
    
    /// See `Model`.
    public static var updatedAtKey: TimestampKey? {
        return nil
    }
}

extension GRDBModel {
    /// Returns the model's ID, throwing an error if the model does not yet have an ID.
    public func requireID() throws -> ID {
        guard let id = self.modelID else {
            throw GRDBKitError.missingIdentifier
        }
        
        return id
    }
    
    /// Access the identifier keyed by `idKey`.
    public var modelID: ID? {
        get {
            let path = Self.idKey
            return self[keyPath: path]
        }
        set {
            let path = Self.idKey
            self[keyPath: path] = newValue
        }
    }
    
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

extension GRDBModel where Self: MutablePersistableRecord {
    mutating func update(timestamping db: Database, date: Date = .init()) throws {
        modelUpdatedAt = date
        try update(db)
    }
    
    mutating func insert(timestamping db: Database, date: Date = .init()) throws {
        modelCreatedAt = date
        modelUpdatedAt = date
        try insert(db)
    }
    
    mutating func save(timestamping db: Database, date: Date = .init()) throws {
        do {
            try update(timestamping: db, date: date)
        } catch PersistenceError.recordNotFound {
            try insert(timestamping: db, date: date)
        }
    }
}
