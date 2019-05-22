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
}
