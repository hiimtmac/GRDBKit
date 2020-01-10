//
//  File.swift
//  
//
//  Created by Taylor McIntyre on 2020-01-10.
//

import Foundation
import GRDB
import GRDBKit

final class Table1: GRDBStringModel, TableRecord, FetchableRecord, PersistableRecord {
    var id: String?
    var name: String
    var age: Int?
    
    init(id: String?, name: String, age: Int?) {
        self.id = id
        self.name = name
        self.age = age
    }
    
    enum Columns: String, ColumnExpression {
        case id
        case name
        case age
    }
    
    static let databaseTableName = "table1"
    
    convenience init(row: Row) {
        let id: ID? = row[Columns.id]
        let name: String = row[Columns.name]
        let age: Int? = row[Columns.age]
        self.init(id: id, name: name, age: age)
    }
    
    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.age] = age
    }
}

final class Table2: GRDBIntModel, TableRecord, FetchableRecord, PersistableRecord {
    var id: Int?
    var name: String
    var active: Bool
    
    init(id: Int?, name: String, active: Bool) {
        self.id = id
        self.name = name
        self.active = active
    }
    
    enum Columns: String, ColumnExpression {
        case id
        case name
        case active
    }
    
    static let databaseTableName = "table2"
    
    convenience init(row: Row) {
        let id: ID? = row[Columns.id]
        let name: String = row[Columns.name]
        let active: Bool = row[Columns.active]
        self.init(id: id, name: name, active: active)
    }
    
    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.active] = active
    }
}

final class Table3: GRDBStringModel, TableRecord, FetchableRecord, PersistableRecord, GRDBIDEquatable {
    var id: String?
    var name: String
    var table2Id: Table2.ID
    
    init(id: String?, name: String, table2Id: Table2.ID) {
        self.id = id
        self.name = name
        self.table2Id = table2Id
    }
    
    enum Columns: String, ColumnExpression {
        case id
        case name
        case table2Id
    }
    
    static let databaseTableName = "table3"
    
    convenience init(row: Row) {
        let id: ID? = row[Columns.id]
        let name: String = row[Columns.name]
        let table2Id: Table2.ID = row[Columns.table2Id]
        self.init(id: id, name: name, table2Id: table2Id)
    }
    
    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.table2Id] = table2Id
    }
}

let createDate = DateComponents(calendar: .current, year: 2018, month: 1, day: 1).date!
let updateDate = DateComponents(calendar: .current, year: 2019, month: 1, day: 1).date!

func seed() throws -> DatabaseQueue {
    let queue = DatabaseQueue()
    try queue.migrate(Schema2.self)
    try queue.write { db in
        try Table1(id: "1", name: "taylor", age: 28).insert(db)
        try Table1(id: "2", name: "person2", age: 27).insert(db)
        try Table1(id: "3", name: "person3", age: 26).insert(db)
        try Table1(id: "4", name: "person4", age: 25).insert(db)
        try Table1(id: "5", name: "person5", age: 24).insert(db)
        try Table2(id: 1, name: "taylor", active: true).insert(db)
        try Table2(id: 2, name: "person2", active: false).insert(db)
        try Table2(id: 3, name: "person3", active: true).insert(db)
        try Table2(id: 4, name: "person4", active: true).insert(db)
        try Table2(id: 5, name: "person5", active: false).insert(db)
        try Table3(id: "1", name: "taylor", table2Id: 1).insert(db)
        try Table3(id: "2", name: "person2", table2Id: 1).insert(db)
        try Table3(id: "3", name: "person3", table2Id: 2).insert(db)
        try Table3(id: "4", name: "person4", table2Id: 2).insert(db)
        try Table3(id: "5", name: "person5", table2Id: 3).insert(db)
    }
    return queue
}
