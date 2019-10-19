//
//  MockUserDAO.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 7/30/19.
//

import Foundation
import StORM
import PostgresStORM

@testable import FebrewaryServerLib

class MockUserDAO: UserDAO {
    override func getAll() throws {
        let row1 = StORMRow()
        row1.data = ["id": 1,
                     "name": "Matt Dias",
                     "email": "me@matt.com",
                     "password": "abc123",
                     "salt": "in moderation",
        ]
        let row2 = StORMRow()
        row2.data = ["id": 2,
                     "name": "Matt Dias",
                     "email": "me2@matt.com",
                     "password": "abc123",
                     "salt": "in moderation",
        ]
        
        self.results.rows = [row1, row2]
    }
    
    override func find(by data: [String : Any]) throws {
        let row1 = StORMRow()
        row1.data = ["id": 1,
                     "name": "Matt Dias",
                     "email": "me@matt.com",
                     "password": "abc123",
                     "salt": "in moderation",
        ]
        
        self.results.rows = [row1]
    }
    
    override func find(by data: [(String, Any)]) throws {
        let row1 = StORMRow()
        row1.data = ["id": 1,
                     "name": "Matt Dias",
                     "email": "me@matt.com",
                     "password": "abc123",
                     "salt": "in moderation",
        ]
        
        self.results.rows = [row1]
    }
    
    override func store(set: (Any) -> Void) throws {
        // no-op
    }
    
    override func store() throws {
        // no-op
    }
    
    override func search(whereClause: String, params: [Any], orderby: [String]) throws {
        assertionFailure("still need to make this")
    }
}

class BadUser: MockUserDAO {
    override func find(by data: [String : Any]) throws {
        let row1 = StORMRow()
        row1.data = ["id": -1,
                     "name": "Matt Dias",
                     "email": "me@matt.com",
                     "password": "abc123",
                     "salt": "in moderation",
        ]
        
        self.results.rows = [row1]
    }
}
