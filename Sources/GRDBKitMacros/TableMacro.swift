import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct TableMacro {
    enum TableMacroError: Error, CustomStringConvertible {
        case unsupportedType
        case nonFinal

        var description: String {
            switch self {
            case .unsupportedType: "@Table can only be applied to classes or structs"
            case .nonFinal: "@Table classes must be marked `final`"
            }
        }
    }

    fileprivate static func accessPrefix(for modifiers: DeclModifierListSyntax) -> String {
        let accessKeyword = modifiers
            .lazy
            .compactMap { modifier -> Keyword? in
                switch modifier.name.tokenKind {
                case .keyword(let keyword)
                where [.public, .package, .internal, .fileprivate, .private, .open].contains(
                    keyword):
                    return keyword
                default:
                    return nil
                }
            }
            .first

        switch accessKeyword {
        case .public, .open: return "public "
        case .package: return "package "
        default: return ""  // internal (explicit or implied), fileprivate, private
        }
    }

    struct ColumnInfo {
        let variableName: String
        let columnName: String
        let typeInfo: TypeInfo

        enum TypeInfo {
            case simple(String, Bool)
            case member(String, String, Bool)

            var description: String {
                switch self {
                case .simple(let name, let optional):
                    return optional ? "\(name)?" : name
                case .member(let base, let name, let optional):
                    return optional ? "\(base).\(name)?" : "\(base).\(name)"
                }
            }

            static func make(from syntax: TypeSyntax) -> Self? {
                if let simple = syntax.as(IdentifierTypeSyntax.self) {
                    return .simple(simple.name.text, false)
                } else if let member = syntax.as(MemberTypeSyntax.self),
                    let base = member.baseType.as(IdentifierTypeSyntax.self)
                {
                    return .member(base.name.text, member.name.text, false)
                } else if let optional = syntax.as(OptionalTypeSyntax.self)?.wrappedType {
                    if let simple = optional.as(IdentifierTypeSyntax.self) {
                        return .simple(simple.name.text, true)
                    } else if let member = optional.as(MemberTypeSyntax.self),
                        let base = member.baseType.as(IdentifierTypeSyntax.self)
                    {
                        return .member(base.name.text, member.name.text, true)
                    }
                }

                return nil
            }

            var isOptional: Bool {
                switch self {
                case .simple(_, let bool): bool
                case .member(_, _, let bool): bool
                }
            }
        }
    }

    static func columnList(from declaration: some DeclGroupSyntax) -> [ColumnInfo] {
        declaration
            .memberBlock
            .members
            .compactMap { member -> ColumnInfo? in
                guard
                    let variable = member.decl.as(VariableDeclSyntax.self),
                    let binding = variable.bindings.first,
                    // is a property
                    let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
                    let typeAnnotation = binding.typeAnnotation?.type,
                    // is a @Column
                    let attribute = variable.attributes
                        .compactMap({ $0.as(AttributeSyntax.self) })
                        .first(where: {
                            $0.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "Column"
                        }),
                    // get info
                    let argumentList = attribute.arguments?.as(LabeledExprListSyntax.self),
                    let argument = argumentList.first,
                    let expression = argument.expression.as(StringLiteralExprSyntax.self),
                    let segment = expression.segments.first?.as(StringSegmentSyntax.self)
                else {
                    return nil
                }

                if let type = ColumnInfo.TypeInfo.make(from: typeAnnotation) {
                    return .init(
                        variableName: identifier.identifier.text,
                        columnName: segment.content.text,
                        typeInfo: type
                    )
                }

                return nil
            }
    }
}

extension TableMacro: ExtensionMacro {
    static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let isClass: Bool
        let modifiers: DeclModifierListSyntax

        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            guard classDecl.modifiers.contains(where: { $0.name.tokenKind == .keyword(.final) })
            else {
                throw TableMacroError.nonFinal
            }
            isClass = true
            modifiers = classDecl.modifiers
        } else if let structDecl = declaration.as(StructDeclSyntax.self) {
            isClass = false
            modifiers = structDecl.modifiers
        } else {
            throw TableMacroError.unsupportedType
        }

        guard
            let argumentList = node.arguments?.as(LabeledExprListSyntax.self),
            let argument = argumentList.first,
            let expression = argument.expression.as(StringLiteralExprSyntax.self),
            let segment = expression.segments.first?.as(StringSegmentSyntax.self)
        else {
            return []
        }

        let access = accessPrefix(for: modifiers)

        let tableRecord = try ExtensionDeclSyntax(
            """
            extension \(type.trimmed): GRDB::TableRecord {
                \(raw: access)static let databaseTableName = \(literal: segment.content.text)
            }
            """
        )

        let columnList = columnList(from: declaration)
        let typeName = type.trimmed.description

        let rowArguments =
            columnList
            .map { "\($0.variableName): row[\(typeName).$\($0.variableName)]" }
            .joined(separator: ", ")

        let convenience = isClass ? "convenience " : ""

        let fetchableRecord = try ExtensionDeclSyntax(
            "extension \(type.trimmed): GRDB::FetchableRecord"
        ) {
            try InitializerDeclSyntax(
                "\(raw: access)\(raw: convenience)init(row: GRDB::Row) throws"
            ) {
                ExprSyntax("self.init(\(raw: rowArguments))")
            }
        }

        let persistableRecord = try ExtensionDeclSyntax(
            "extension \(type.trimmed): GRDB::PersistableRecord"
        ) {
            try FunctionDeclSyntax(
                "\(raw: access)func encode(to container: inout GRDB::PersistenceContainer) throws"
            ) {
                for info in columnList {
                    ExprSyntax(
                        "container[\(raw: typeName).$\(raw: info.variableName)] = \(raw: info.variableName)"
                    )
                }
            }
        }

        return [tableRecord, fetchableRecord, persistableRecord]
    }
}

extension TableMacro: MemberMacro {
    struct BelongsToInfo {
        let variableName: String
        let type: String
        /// The primary key column expression on the parent, e.g. `"Parent.$id"`.
        let pkExpr: String
        /// The foreign key column expression on this type, e.g. `"Self.$parentId"`.
        let fkExpr: String
    }

    struct HasManyInfo {
        let variableName: String
        let type: String
        /// The primary key column expression on this type, e.g. `"Self.$id"`.
        let pkExpr: String
        /// The foreign key column expression on the child type, e.g. `"Child.$parentId"`.
        let fkExpr: String
    }

    struct HasOneInfo {
        let variableName: String
        let type: String
        /// The primary key column expression on this type, e.g. `"Self.$id"`.
        let pkExpr: String
        /// The foreign key column expression on the related type, e.g. `"Related.$parentId"`.
        let fkExpr: String
    }

    /// Resolves a `\Type.Type.$column` key path expression to a string like `"Type.$column"`.
    /// Substitutes `Self` with `inferredRoot` (the concrete enclosing type name).
    private static func resolveColumnKeyPath(
        _ expr: ExprSyntax,
        inferredRoot: String? = nil
    ) -> String? {
        guard
            let keyPath = expr.as(KeyPathExprSyntax.self),
            keyPath.components.count == 1,
            let firstComponent = keyPath.components.first,
            case .property(let prop) = firstComponent.component
        else {
            return nil
        }

        let propName = prop.declName.baseName.text

        if let root = keyPath.root {
            // `\Type.Type.$col` — static member key path; root is a MetatypeTypeSyntax.
            if let metatype = root.as(MetatypeTypeSyntax.self),
                let base = metatype.baseType.as(IdentifierTypeSyntax.self)
            {
                let rootName =
                    base.name.text == "Self" ? (inferredRoot ?? base.name.text) : base.name.text
                return "\(rootName).\(propName)"
            }
            // `\Type.$col` — instance key path fallback.
            if let ident = root.as(IdentifierTypeSyntax.self) {
                let rootName =
                    ident.name.text == "Self" ? (inferredRoot ?? ident.name.text) : ident.name.text
                return "\(rootName).\(propName)"
            }
        } else if let inferredRoot {
            return "\(inferredRoot).\(propName)"
        }

        return nil
    }

    private static func relationshipType(
        member: MemberBlockItemListSyntax.Element,
        type: String
    ) -> (IdentifierPatternSyntax, IdentifierTypeSyntax, AttributeSyntax)? {
        guard
            let variable = member.decl.as(VariableDeclSyntax.self),
            let binding = variable.bindings.first,
            // is a property
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
            let typeAnnotation = binding.typeAnnotation?.type.as(IdentifierTypeSyntax.self),
            typeAnnotation.name.text == "QueryInterfaceRequest",
            let generic = typeAnnotation.genericArgumentClause,
            let argument = generic.arguments.first?.argument.as(IdentifierTypeSyntax.self),
            // is a @HasMany|@HasOne|@BelongsTo
            let attribute = variable.attributes
                .compactMap({ $0.as(AttributeSyntax.self) })
                .first(where: {
                    $0.attributeName.as(IdentifierTypeSyntax.self)?.name.text == type
                })
        else {
            return nil
        }

        return (identifier, argument, attribute)
    }

    static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let modifiers: DeclModifierListSyntax
        let selfTypeName: String

        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            guard classDecl.modifiers.contains(where: { $0.name.tokenKind == .keyword(.final) })
            else {
                throw TableMacroError.nonFinal
            }
            modifiers = classDecl.modifiers
            selfTypeName = classDecl.name.text
        } else if let structDecl = declaration.as(StructDeclSyntax.self) {
            modifiers = structDecl.modifiers
            selfTypeName = structDecl.name.text
        } else {
            throw TableMacroError.unsupportedType
        }

        let access = accessPrefix(for: modifiers)

        let columnList = columnList(from: declaration)

        let columnAccessors = columnList.map { info -> DeclSyntax in
            """
            \(raw: access)static let $\(raw: info.variableName) = GRDB::Column(\(literal: info.columnName))
            """
        }

        let parameters =
            columnList
            .map { info -> String in
                let defaultValue = info.typeInfo.isOptional ? " = nil" : ""
                return "\(info.variableName): \(info.typeInfo.description)\(defaultValue)"
            }
            .joined(separator: ", ")

        let initializer = try InitializerDeclSyntax(
            "\(raw: access)init(\(raw: parameters))"
        ) {
            for info in columnList {
                ExprSyntax("self.\(raw: info.variableName) = \(raw: info.variableName)")
            }
        }

        let belongsTo = declaration
            .memberBlock
            .members
            .compactMap { member -> BelongsToInfo? in
                guard
                    let (identifier, argument, attribute) = relationshipType(
                        member: member, type: "BelongsTo"),
                    let args = attribute.arguments?.as(LabeledExprListSyntax.self),
                    args.count == 2,
                    let pkExpr = resolveColumnKeyPath(
                        args[args.startIndex].expression,
                        inferredRoot: argument.name.text),
                    let fkExpr = resolveColumnKeyPath(
                        args[args.index(after: args.startIndex)].expression,
                        inferredRoot: selfTypeName)
                else {
                    return nil
                }

                return .init(
                    variableName: identifier.identifier.text,
                    type: argument.name.text,
                    pkExpr: pkExpr,
                    fkExpr: fkExpr
                )
            }
            .map { info -> DeclSyntax in
                """
                \(raw: access)static let \(raw: info.variableName) = belongsTo(\(raw: info.type).self, using: GRDB::ForeignKey([\(raw: info.fkExpr)], to: [\(raw: info.pkExpr)]))
                """
            }

        let hasMany = declaration
            .memberBlock
            .members
            .compactMap { member -> HasManyInfo? in
                guard
                    let (identifier, argument, attribute) = relationshipType(
                        member: member, type: "HasMany"),
                    let args = attribute.arguments?.as(LabeledExprListSyntax.self),
                    args.count == 2,
                    let pkExpr = resolveColumnKeyPath(
                        args[args.startIndex].expression,
                        inferredRoot: selfTypeName),
                    let fkExpr = resolveColumnKeyPath(
                        args[args.index(after: args.startIndex)].expression,
                        inferredRoot: argument.name.text)
                else {
                    return nil
                }

                return .init(
                    variableName: identifier.identifier.text,
                    type: argument.name.text,
                    pkExpr: pkExpr,
                    fkExpr: fkExpr
                )
            }
            .map { info -> DeclSyntax in
                """
                \(raw: access)static let \(raw: info.variableName) = hasMany(\(raw: info.type).self, using: GRDB::ForeignKey([\(raw: info.fkExpr)], to: [\(raw: info.pkExpr)]))
                """
            }

        let hasOne = declaration
            .memberBlock
            .members
            .compactMap { member -> HasOneInfo? in
                guard
                    let (identifier, argument, attribute) = relationshipType(
                        member: member, type: "HasOne"),
                    let args = attribute.arguments?.as(LabeledExprListSyntax.self),
                    args.count == 2,
                    let pkExpr = resolveColumnKeyPath(
                        args[args.startIndex].expression,
                        inferredRoot: selfTypeName),
                    let fkExpr = resolveColumnKeyPath(
                        args[args.index(after: args.startIndex)].expression,
                        inferredRoot: argument.name.text)
                else {
                    return nil
                }

                return .init(
                    variableName: identifier.identifier.text,
                    type: argument.name.text,
                    pkExpr: pkExpr,
                    fkExpr: fkExpr
                )
            }
            .map { info -> DeclSyntax in
                """
                \(raw: access)static let \(raw: info.variableName) = hasOne(\(raw: info.type).self, using: GRDB::ForeignKey([\(raw: info.fkExpr)], to: [\(raw: info.pkExpr)]))
                """
            }

        return [DeclSyntax(initializer)] + columnAccessors + belongsTo + hasMany + hasOne
    }
}
