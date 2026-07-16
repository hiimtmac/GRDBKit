import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// Shared helper, e.g. in a RequestAccessorExpansion.swift
enum RequestAccessor {
    static func expansion(for declaration: some DeclSyntaxProtocol) -> [AccessorDeclSyntax] {
        guard
            let variable = declaration.as(VariableDeclSyntax.self),
            let binding = variable.bindings.first,
            let pattern = binding.pattern.as(IdentifierPatternSyntax.self)
        else {
            return []
        }

        return [
            """
            get {
                request(for: Self.\(raw: pattern.identifier.text))
            }
            """
        ]
    }
}

struct HasManyMacro {}
extension HasManyMacro: AccessorMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        RequestAccessor.expansion(for: declaration)
    }
}

struct HasOneMacro {}
extension HasOneMacro: AccessorMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        RequestAccessor.expansion(for: declaration)
    }
}

struct BelongsToMacro {}
extension BelongsToMacro: AccessorMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        RequestAccessor.expansion(for: declaration)
    }
}
