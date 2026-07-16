public import GRDB

public protocol Migration: Sendable {
    static var name: String { get }
    static var foreignKeyChecks: DatabaseMigrator.ForeignKeyChecks { get }
    static func willMigrate(database: Database) throws
    static func migrate(database: Database) throws
    static func didMigrate(database: Database) throws
}

extension Migration {
    public static var name: String { "\(Self.self)" }
    public static var foreignKeyChecks: DatabaseMigrator.ForeignKeyChecks { .deferred }
    public static func willMigrate(database: Database) throws {}
    public static func didMigrate(database: Database) throws {}

    static func register(migrator: inout DatabaseMigrator) {
        migrator.registerMigration(name, foreignKeyChecks: foreignKeyChecks) { db in
            try willMigrate(database: db)
            try migrate(database: db)
            try didMigrate(database: db)
        }
    }
}

public protocol SchemaMigrationPlan {
    static var migrations: [any Migration.Type] { get }
}

extension SchemaMigrationPlan {
    static func register(migrator: inout DatabaseMigrator) {
        migrations.forEach { migration in
            migration.register(migrator: &migrator)
        }
    }
}

extension DatabaseWriter {
    func _migrate(
        using migrationPlan: any SchemaMigrationPlan.Type,
        upTo migration: (any Migration.Type)? = nil,
        eraseDatabaseOnSchemaChange: Bool
    ) throws {
        var migrator = DatabaseMigrator()
        migrator.eraseDatabaseOnSchemaChange = eraseDatabaseOnSchemaChange
        migrationPlan.register(migrator: &migrator)

        if let migration {
            try migrator.migrate(self, upTo: migration.name)
        } else {
            try migrator.migrate(self)
        }
    }

    public func migrate(
        using migrationPlan: any SchemaMigrationPlan.Type,
        upTo migration: (any Migration.Type)? = nil
    ) throws {
        try _migrate(
            using: migrationPlan,
            upTo: migration,
            eraseDatabaseOnSchemaChange: false
        )
    }

    #if DEBUG
        @_disfavoredOverload
        public func migrate(
            using migrationPlan: any SchemaMigrationPlan.Type,
            upTo migration: (any Migration.Type)? = nil,
            eraseDatabaseOnSchemaChange: Bool = false
        ) throws {
            try _migrate(
                using: migrationPlan,
                upTo: migration,
                eraseDatabaseOnSchemaChange: eraseDatabaseOnSchemaChange
            )
        }
    #endif
}
