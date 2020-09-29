//
//  Model.swift
//  GRDBKit
//
//  Created by Taylor McIntyre on 2019-01-07.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation

public protocol GRDBModel: Identifiable {}

extension GRDBModel where ID: OptionalType {
    /// Returns the model's ID, throwing an error if the model does not yet have an ID.
    public func requireID() throws -> ID {
        guard let id = self.id.asOptional else {
            throw GRDBKitError.missingIdentifier
        }
        
        return id as! ID
    }
}
