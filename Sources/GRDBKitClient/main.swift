import GRDB
import GRDBKit

@Table(name: "test")
public final class Test {
    @Column(name: "test_column")
    var testColumn: String

    @Column(name: "another")
    var another: String?
}

@Table(name: "tester")
public struct Tester {
    @Column(name: "test_column")
    var testColumn: String

    @Column(name: "another")
    var another: String?

    @BelongsTo(\Test.Type.$testColumn, \Tester.Type.$testColumn)
    var test: QueryInterfaceRequest<Test>
}

@Table(name: "testied")
public final class Testied {
    @Column(name: "test_column")
    var testColumn: String

    @Column(name: "another")
    var another: String?

    @HasMany(\Testied.Type.$testColumn, \Tester.Type.$testColumn)
    var tester: QueryInterfaceRequest<Tester>
}

let test = Test(testColumn: "hi", another: "hi")
// print(Test.testColumn)
print(Test.$testColumn)
print(Test.databaseTableName)

struct Temp: FetchableRecord {
    let testColumn: String
    let another: String?

    init(row: Row) throws {
        self.testColumn = row[Test.$testColumn]
        self.another = row[Test.$another]
    }
}

struct Test1: Migration {
    static func willMigrate(database: Database) throws {
        print("\(Self.self): \(#function)")
    }

    static func migrate(database: Database) throws {
        print("\(Self.self): \(#function)")
    }
}

struct Test2: Migration {
    static func migrate(database: Database) throws {
        print("\(Self.self): \(#function)")
    }

    static func didMigrate(database: Database) throws {
        print("\(Self.self): \(#function)")
    }
}

enum MigrationPlan: SchemaMigrationPlan {
    static let migrations: [any Migration.Type] = [
        Test1.self,
        Test2.self,
    ]
}

let queue = try! DatabaseQueue()
try! queue.migrate(using: MigrationPlan.self)
//try! queue.migrate(using: MigrationPlan.self, upTo: Test1.self)
