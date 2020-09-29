# GRDBKit

This library is a fusion of ideas from Vapor's [Fluent](https://github.com/vapor/fluent) typealiases to be used with [GRDB](https://github.com/groue/GRDB.swift)

## Requirements

- Swift 5.3+

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.

```swift
import PackageDescription

let package = Package(
  name: "TestProject",
  dependencies: [
    .package(url: "https://github.com/hiimtmac/GRDBKit.git", from: "2.0.0")
  ]
)
```

### Cocoapods

```ruby
source 'https://github.com/hiimtmac/specs.git'
source 'https://cdn.cocoapods.org/'

target 'MyApp' do
  pod 'GRDBKit', '~> 1.0'
end
```

## Usage

### Migration Help

```swift
// Setup
enum Schema1: MigrationVersion, CaseIterable {
    case m1
    case m2
    case m3
    
    var migrationType: Migration.Type {
        switch self {
        case .m1: return Migration1.self
        case .m2: return Migration2.self
        case .m3: return Migration3.self
        }
    }
    
    var previousMigration: Schema1? {
        switch self {
        case .m1: return nil
        case .m2: return .m1
        case .m3: return .m2
        }
    }
}

struct Migration1: Migration {
    static let migrationIdentifier = "Migration123"
    static func register(on migrator: inout DatabaseMigrator) throws {
        migrator.registerMigrationWithDeferredForeignKeyCheck(migrationIdentifier) { db in
            try db.create(table: "table1") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("age", .integer)
            }
        }
    }
}

struct Migration2: Migration {
    static func register(on migrator: inout DatabaseMigrator) throws {
        migrator.registerMigrationWithDeferredForeignKeyCheck(migrationIdentifier) { db in
            try db.create(table: "table2") { t in
                t.column("id", .integer).primaryKey()
                t.column("name", .text).notNull()
                t.column("active", .boolean).notNull()
            }
        }
    }
}

struct Migration3: Migration {
    static var migrationIdentifier: String { Schema1.m3.rawValue }
    static func register(on migrator: inout DatabaseMigrator) throws {
        migrator.registerMigrationWithDeferredForeignKeyCheck(migrationIdentifier) { db in
            try db.create(table: "table3") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("table2Id", .text).notNull().references("table2")
            }
        }
    }
}

// Usage
let queue1 = DatabaseQueue()
try queue1.migrateTo(version: Schema1.m2) // only migrate to 2/3
try queue1.migrate(Schema1.self) // will do all migrations
```
