//
//  IntModel.swift
//  GRDBKit
//
//  Created by Taylor McIntyre on 2019-02-05.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation

/// A SQLite database model with `Int` primary key.
public protocol GRDBIntModel: GRDBModel where Self.ID == Int {
    /// This SQLite Model's unique identifier.
    var id: Int? { get set }
}

extension GRDBIntModel {
    /// Default conformance
    public static var idKey: IDKey { return \.id }
}
