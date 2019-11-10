//
//  MockEventDAO.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 10/19/19.
//

import Foundation
import StORM
import PostgresStORM

@testable import FebrewaryServerLib

class MockManyEventDAO: EventDAO {
    override func search(whereClause: String, params: [Any], orderby: [String]) throws {
        let row1 = StORMRow()
        row1.data = ["id": 1,
                     "name": "Some Event",
                     "address": "my home",
                     "date": "another day",
                     "createdby": 1,
                     "pourerid": 1,
                     "isover": false,
                     "hasstarted": false
        ]
        let row2 = StORMRow()
        row2.data = ["id": 2,
                     "name": "Some Event",
                     "address": "my home",
                     "date": "another day",
                     "createdby": 1,
                     "pourerid": 1,
                     "isover": false,
                     "hasstarted": false
        ]
        
        self.results.rows = [row1, row2]
    }
}

class MockNoEventDAO: EventDAO {
    override func find(by data: [(String, Any)]) throws {
        self.results.rows = []
    }
}

class MockSingleEventDAO: EventDAO {
    override func find(by data: [(String, Any)]) throws {
        let row1 = StORMRow()
        row1.data = ["id": 1,
                     "name": "Some Event",
                     "address": "my home",
                     "date": "another day",
                     "createdby": 1,
                     "pourerid": 1,
                     "isover": false,
                     "hasstarted": false
        ]
        
        self.results.rows = [row1]
    }
    
    override func save(set: (Any) -> Void) throws {
        set(1)
    }
}
