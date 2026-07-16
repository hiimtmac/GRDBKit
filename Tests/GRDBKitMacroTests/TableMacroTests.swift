import SwiftSyntaxMacrosTestSupport
import Testing

@Suite
struct TableMacroTests {
    @Test(arguments: [
        ("public ", "struct ", ""),
        ("public ", "final class ", "convenience "),
        ("package ", "struct ", ""),
        ("package ", "final class ", "convenience "),
        ("", "struct ", ""),
        ("", "final class ", "convenience "),
    ])
    func testMacro(args: (visibility: String, type: String, convenience: String)) {
        let (visibility, type, convenience) = args
        assertMacroExpansion(
            """
            @Table(name: "test_table")
            \(visibility)\(type)Test {
                @Column(name: "test_column")
                var testColumn: Int

                @Column(name: "another")
                var another: Int

                @Column(name: "some_id")
                var someId: Some.ID

                @Column(name: "optional_id")
                var optionalId: Optional.ID?

                @BelongsTo(\\Equipment.Type.$id, \\Self.Type.$someId)
                var equipment: QueryInterfaceRequest<Equipment>

                @HasMany(\\Self.Type.$testColumn, \\Company.Type.$testId)
                var companies: QueryInterfaceRequest<Company>

                @HasOne(\\Self.Type.$testColumn, \\TestChild.Type.$testId)
                var test: QueryInterfaceRequest<TestChild>

                var another: String

                var more: String { "" }
            }
            """,
            expandedSource: """

                \(visibility)\(type)Test {
                    var testColumn: Int
                    var another: Int
                    var someId: Some.ID
                    var optionalId: Optional.ID?
                    var equipment: QueryInterfaceRequest<Equipment> {
                        get {
                            request(for: Self.equipment)
                        }
                    }
                    var companies: QueryInterfaceRequest<Company> {
                        get {
                            request(for: Self.companies)
                        }
                    }
                    var test: QueryInterfaceRequest<TestChild> {
                        get {
                            request(for: Self.test)
                        }
                    }

                    var another: String

                    var more: String { "" }

                    \(visibility)init(testColumn: Int, another: Int, someId: Some.ID, optionalId: Optional.ID? = nil) {
                        self.testColumn = testColumn
                        self.another = another
                        self.someId = someId
                        self.optionalId = optionalId
                    }

                    \(visibility)static let $testColumn = GRDB::Column("test_column")

                    \(visibility)static let $another = GRDB::Column("another")

                    \(visibility)static let $someId = GRDB::Column("some_id")

                    \(visibility)static let $optionalId = GRDB::Column("optional_id")

                    \(visibility)static let equipment = belongsTo(Equipment.self, using: GRDB::ForeignKey([Test.$someId], to: [Equipment.$id]))

                    \(visibility)static let companies = hasMany(Company.self, using: GRDB::ForeignKey([Company.$testId], to: [Test.$testColumn]))

                    \(visibility)static let test = hasOne(TestChild.self, using: GRDB::ForeignKey([TestChild.$testId], to: [Test.$testColumn]))
                }

                extension Test: GRDB::TableRecord {
                    \(visibility)static let databaseTableName = "test_table"
                }

                extension Test: GRDB::FetchableRecord {
                    \(visibility)\(convenience)init(row: GRDB::Row) throws {
                        self.init(testColumn: row[Test.$testColumn], another: row[Test.$another], someId: row[Test.$someId], optionalId: row[Test.$optionalId])
                    }
                }

                extension Test: GRDB::PersistableRecord {
                    \(visibility)func encode(to container: inout GRDB::PersistenceContainer) throws {
                        container[Test.$testColumn] = testColumn
                        container[Test.$another] = another
                        container[Test.$someId] = someId
                        container[Test.$optionalId] = optionalId
                    }
                }
                """,
            macros: testMacros
        )
    }
}
