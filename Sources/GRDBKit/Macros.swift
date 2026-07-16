import GRDB

@attached(peer)
public macro Column(name: String) = #externalMacro(module: "GRDBKitMacros", type: "ColumnMacro")

@attached(
    extension, conformances: TableRecord, FetchableRecord, PersistableRecord,
    names: named(databaseTableName), named(init(row:)), named(encode(to:)))
@attached(member, names: named(databaseTableName), named(init(row:)), named(encode(to:)), arbitrary)
public macro Table(name: String) = #externalMacro(module: "GRDBKitMacros", type: "TableMacro")

// MARK: - BelongsTo

/// - Parameters:
///   - pk: The primary key column on the parent type, e.g. `Parent.$id`
///   - fk: The foreign key column on this type, e.g. `Self.$parentId`
@attached(accessor)
public macro BelongsTo(_ pk: AnyKeyPath, _ fk: AnyKeyPath) =
    #externalMacro(module: "GRDBKitMacros", type: "BelongsToMacro")

// MARK: - HasMany

/// - Parameters:
///   - pk: The primary key column on this type, e.g. `\Self.Type.$id`
///   - fk: The foreign key column on the child type, e.g. `\Child.Type.$parentId`
@attached(accessor)
public macro HasMany(_ pk: AnyKeyPath, _ fk: AnyKeyPath) =
    #externalMacro(module: "GRDBKitMacros", type: "HasManyMacro")

// MARK: - HasOne

/// - Parameters:
///   - pk: The primary key column on this type, e.g. `\Self.Type.$id`
///   - fk: The foreign key column on the related type, e.g. `\Related.Type.$parentId`
@attached(accessor)
public macro HasOne(_ pk: AnyKeyPath, _ fk: AnyKeyPath) =
    #externalMacro(module: "GRDBKitMacros", type: "HasOneMacro")
