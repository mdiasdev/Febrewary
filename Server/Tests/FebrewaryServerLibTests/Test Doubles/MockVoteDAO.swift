//
//  MockVoteDAO.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 11/16/19.
//

import Foundation
import StORM
import PostgresStORM

@testable import FebrewaryServerLib

class MockNoVoteDAO: VoteDAO {
    override func find(by data: [(String, Any)]) throws {
        self.results.rows = []
    }
    
    override func save(set: (Any) -> Void) throws {
        set(1)
    }
}

class MockSingleVoteDAO: VoteDAO {
    override func find(by data: [(String, Any)]) throws {
        let row1 = StORMRow()
        row1.data = ["id": 1,
                     "userid": 1,
                     "eventbeerid": 1,
                     "eventid": 1,
                     "score": 1
        ]
        
        self.results.rows = [row1]
    }
}
