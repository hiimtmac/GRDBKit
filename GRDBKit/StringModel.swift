//
//  StringModel.swift
//  GRDBKit
//
//  Created by Taylor McIntyre on 2019-02-05.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation

/// A SQLite database model with `String` primary key.
public protocol GRDBStringModel: GRDBModel where Self.ID == String {
    /// This SQLite Model's unique identifier.
    var id: String? { get set }
}

extension GRDBStringModel {
    /// See `Model`
    public static var idKey: IDKey { return \.id }
}
