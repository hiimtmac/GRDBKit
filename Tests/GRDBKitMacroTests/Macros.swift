import SwiftSyntaxMacros

@testable import GRDBKitMacros

let testMacros: [String: Macro.Type] = [
    "Column": ColumnMacro.self,
    "Table": TableMacro.self,
    "BelongsTo": BelongsToMacro.self,
    "HasMany": HasManyMacro.self,
    "HasOne": HasOneMacro.self,
]
