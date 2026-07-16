import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct ColumnMacro {}

extension ColumnMacro: PeerMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}
