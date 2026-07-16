# GRDBKit

Swift macros and helpers that reduce boilerplate when working with [GRDB](https://github.com/groue/GRDB.swift).

- `@Table` / `@Column` — generate `TableRecord`, `FetchableRecord`, and `PersistableRecord` conformance from your properties.
- `@BelongsTo` / `@HasMany` / `@HasOne` — generate GRDB association accessors from key paths.
- Migration protocol and `SchemaMigrationPlan` for ordered, testable migrations.
- Small `PersistableRecord` conveniences (`saving`, `inserting`).

## Requirements

- Swift tools version 6.3+
- macOS 26 / iOS 26 / watchOS 26
- [GRDB](https://github.com/groue/GRDB.swift) 7.11.0+

## Installation

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

```swift
import PackageDescription

let package = Package(
    name: "MyProject",
    dependencies: [
        .package(url: "https://github.com/hiimtmac/GRDBKit.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "MyTarget",
            dependencies: ["GRDBKit"]
        )
    ]
)
```

## Usage

### `@Table` and `@Column`

Annotate a `class` (must be `final`) or `struct` with `@Table(name:)`, and annotate each stored property that maps to a database column with `@Column(name:)`. The macro generates:

- `TableRecord` conformance (`databaseTableName`)
- A memberwise `init` (optional columns default to `nil`)
- Static `Column` accessors, e.g. `Test.$testColumn`
- `FetchableRecord` conformance (`init(row:)`)
- `PersistableRecord` conformance (`encode(to:)`)

```swift
import GRDB
import GRDBKit

@Table(name: "test")
public final class Test {
    @Column(name: "test_column")
    var testColumn: String

    @Column(name: "another")
    var another: String?
}

let test = Test(testColumn: "hi", another: nil)
print(Test.$testColumn)       // Column("test_column")
print(Test.databaseTableName) // "test"
```

### Relationships

Declare an association as a `QueryInterfaceRequest<Related>` property and annotate it with `@BelongsTo`, `@HasMany`, or `@HasOne`, passing the primary key and foreign key columns as key paths.

```swift
@Table(name: "tester")
public struct Tester {
    @Column(name: "test_column")
    var testColumn: String

    @BelongsTo(\Test.Type.$testColumn, \Tester.Type.$testColumn)
    var test: QueryInterfaceRequest<Test>
}

@Table(name: "testied")
public final class Testied {
    @Column(name: "test_column")
    var testColumn: String

    @HasMany(\Testied.Type.$testColumn, \Tester.Type.$testColumn)
    var tester: QueryInterfaceRequest<Tester>
}
```

`@BelongsTo` and `@HasOne` work the same way — `@HasOne` generates a `hasOne` association instead of `hasMany`.

### Migrations

Conform each migration to `Migration`, then group them in a `SchemaMigrationPlan`. Migrations run in array order via `DatabaseMigrator`.

```swift
struct CreateTester: Migration {
    static func migrate(database: Database) throws {
        try database.create(table: "tester") { t in
            t.column("id", .integer).primaryKey()
            t.column("test_column", .text).notNull()
        }
    }
}

struct AddAnotherColumn: Migration {
    static func migrate(database: Database) throws {
        try database.alter(table: "tester") { t in
            t.add(column: "another", .text)
        }
    }
}

enum MigrationPlan: SchemaMigrationPlan {
    static let migrations: [any Migration.Type] = [
        CreateTester.self,
        AddAnotherColumn.self,
    ]
}

let queue = try DatabaseQueue()
try queue.migrate(using: MigrationPlan.self)
```

`Migration` also has optional `willMigrate(database:)` / `didMigrate(database:)` hooks that run before/after `migrate(database:)`, and a `foreignKeyChecks` property (defaults to `.deferred`) forwarded to `DatabaseMigrator.registerMigration`.

To migrate only partway through a plan, pass `upTo:`:

```swift
try queue.migrate(using: MigrationPlan.self, upTo: CreateTester.self)
```

In `DEBUG` builds, `migrate(using:upTo:eraseDatabaseOnSchemaChange:)` is also available for wiping the database when the schema changes.

### `PersistableRecord` conveniences

`saving` and `inserting` mirror GRDB's `save`/`insert` but return `Self`, which is useful for chaining:

```swift
let saved = try test.saving(db)
let inserted = try test.inserting(db)
```
