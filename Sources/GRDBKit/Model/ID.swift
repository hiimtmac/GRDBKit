//
//  ID.swift
//  GRDBKit
//
//  Created by Taylor McIntyre on 2019-01-07.
//  Copyright © 2019 hiimtmac. All rights reserved.
//

import Foundation

public protocol ID: Codable, Equatable {}

extension Int: ID {}
extension String: ID {}
//extension UUID: ID {}
