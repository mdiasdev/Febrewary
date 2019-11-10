//
//  MockEventBeerDAO.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 11/10/19.
//

import Foundation
import StORM
import PostgresStORM

@testable import FebrewaryServerLib

class MockNoEventBeerDAO: EventBeerDAO {
    override func find(by data: [(String, Any)]) throws {
        self.results.rows = []
    }
}

class MockManyEventBeerDAO: EventBeerDAO {
    override func find(by data: [(String, Any)]) throws {
        let row1 = StORMRow()
        row1.data = ["id": 1,
                     "userid": 1,
                     "beerid": 1,
                     "eventid": 1,
        ]
        
        let row2 = StORMRow()
        row2.data = ["id": 2,
                     "userid": 2,
                     "beerid": 2,
                     "eventid": 2,
        ]
        
        self.results.rows = [row1, row2]
    }
}

class MockSingleEventBeerDAO: EventBeerDAO {
    override func find(by data: [(String, Any)]) throws {
        let row1 = StORMRow()
        row1.data = ["id": 1,
                     "userid": 1,
                     "beerid": 1,
                     "eventid": 1,
        ]
        
        self.results.rows = [row1]
    }
    
    override func save(set: (Any) -> Void) throws {
        set(1)
    }
}
