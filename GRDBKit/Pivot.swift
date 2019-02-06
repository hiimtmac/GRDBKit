//
//  Pivot.swift
//  GRDBKit
//
//  Created by Taylor McIntyre on 2019-01-08.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation

public protocol GRDBPivot: GRDBModel {
    /// The Left model for this pivot.
    associatedtype Left: GRDBModel
    
    /// The Right model for this pivot.
    associatedtype Right: GRDBModel
    
    /// Key path type for left id key.
    typealias LeftIDKey = WritableKeyPath<Self, Left.ID>
    
    /// Key for accessing left id.
    static var leftIDKey: LeftIDKey { get }
    
    /// Key path type for right id key.
    typealias RightIDKey = WritableKeyPath<Self, Right.ID>
    
    /// Key for accessing right id.
    static var rightIDKey: RightIDKey { get }
}

/// A SQLite database pivot.
public protocol GRDBIntPivot: GRDBPivot, GRDBIntModel { }

/// A SQLite database pivot.
public protocol GRDBStringPivot: GRDBPivot, GRDBStringModel { }
