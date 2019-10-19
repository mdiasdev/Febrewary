//
//  MockAttendeeDAO.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 10/19/19.
//

import Foundation
import StORM
import PostgresStORM

@testable import FebrewaryServerLib

class MockNoAttendeeDAO: AttendeeDAO {
    override func find(by data: [(String, Any)]) throws {
        self.results.rows = []
    }
}

class MockSingleAttendeeDAO: AttendeeDAO {
    override func find(by data: [(String, Any)]) throws {
        let row1 = StORMRow()
        row1.data = ["id": 1,
                     "eventid": 1,
                     "eventbeerid": 1,
                     "userid": 1,
        ]
        
        self.results.rows = [row1]
    }
    
    override func store(set: (Any) -> Void) throws {
        set(1)
    }
}

class MockManyAttendeeDAO: AttendeeDAO {
    override func find(by data: [(String, Any)]) throws {
        let row1 = StORMRow()
        row1.data = ["id": 1,
                     "eventid": 1,
                     "eventbeerid": 1,
                     "userid": 1,
        ]
        
        let row2 = StORMRow()
        row2.data = ["id": 2,
                     "eventid": 2,
                     "eventbeerid": 2,
                     "userid": 1,
        ]
        
        self.results.rows = [row1, row2]
    }
}
