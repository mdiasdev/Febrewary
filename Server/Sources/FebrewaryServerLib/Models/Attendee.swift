//
//  Attendee.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 8/3/19.
//

import Foundation
import StORM
import PostgresStORM

class Attendee: DAO {
    var id: Int = 0
    var eventId: Int = 0
    var eventBeerId: Int = 0
    var userId: Int = 0
    
    override open func table() -> String { return "attendee" }
    
    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        eventId = this.data["eventid"] as? Int ?? 0
        eventBeerId = this.data["eventbeerid"] as? Int ?? 0
        userId = this.data["userid"] as? Int ?? 0
    }
    
    func rows() -> [Attendee] {
        
        let rows = self.results.rows
        var attendees = [Attendee]()
        
        for row in rows {
            let attendee = Attendee()
            attendee.to(row)
            attendees.append(attendee)
        }
        
        return attendees
    }
}
