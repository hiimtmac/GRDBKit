public import GRDB

extension PersistableRecord {
    @discardableResult
    public func saving(_ db: Database) throws -> Self {
        try save(db)
        return self
    }
    
    @discardableResult
    public func inserting(_ db: Database) throws -> Self {
        try insert(db)
        return self
    }
}
