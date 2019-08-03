//
//  MockUser.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 7/30/19.
//

import Foundation
import StORM
import PostgresStORM

@testable import FebrewaryServerLib

class MockUser: User {
    override func getAll() throws {
        let row1 = StORMRow()
        row1.data = ["id": 1,
                     "firstName": "Matt",
                     "lastName": "Dias",
                     "email": "me@matt.com",
                     "password": "abc123",
                     "salt": "in moderation",
                     "beers": [1],
                     "events": [1]
        ]
        let row2 = StORMRow()
        row2.data = ["id": 2,
                     "firstName": "Matt",
                     "lastName": "Dias",
                     "email": "me2@matt.com",
                     "password": "abc123",
                     "salt": "in moderation",
                     "beers": [2],
                     "events": [2]
        ]
        
        self.results.rows = [row1, row2]
    }
    
    override func find(by data: [String : Any]) throws {
        let row1 = StORMRow()
        row1.data = ["id": 1,
                     "firstName": "Matt",
                     "lastName": "Dias",
                     "email": "me@matt.com",
                     "password": "abc123",
                     "salt": "in moderation",
                     "beers": [1],
                     "events": [1]
        ]
        
        self.results.rows = [row1]
    }
    
    override func find(by data: [(String, Any)]) throws {
        assertionFailure("still need to make this")
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
