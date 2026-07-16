import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct GRDBKitPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        ColumnMacro.self,
        TableMacro.self,
        BelongsToMacro.self,
        HasManyMacro.self,
        HasOneMacro.self,
    ]
}
