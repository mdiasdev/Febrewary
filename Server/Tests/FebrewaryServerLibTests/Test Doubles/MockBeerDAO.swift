//
//  MockBeerDAO.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 11/24/19.
//

import Foundation
import StORM
import PostgresStORM

@testable import FebrewaryServerLib

class MockNoBeerDAO: BeerDAO {
    override func find(by data: [(String, Any)]) throws {
        self.results.rows = []
    }
    
    override func save(set: (Any) -> Void) throws {
        set(1)
    }
}

class MockSingleBeerDAO: BeerDAO {
    override func find(by data: [(String, Any)]) throws {
        let row1 = StORMRow()
        row1.data = ["id": 1,
                     "name": "so good",
                     "brewer": "so good",
                     "abv": 1.0,
                     "addedby": 1,
                     "totalscore": 0,
                     "totalvote": 0,
        ]
        
        self.results.rows = [row1]
    }
    
    override func save(set: (Any) -> Void) throws {
        set(1)
    }
}
