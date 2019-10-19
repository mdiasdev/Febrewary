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

class MockEventDAO: EventDAO {
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
