//
//  AttendeeDataHandler.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 10/12/19.
//

import Foundation

struct Attendee: Codable {
    var id: Int = 0
    var eventId: Int = 0
    var eventBeerId: Int = 0
    var userId: Int = 0
}

class AttendeeDataHandler {
    func attendee(fromEventId eventId: Int, andUserId userId: Int) throws -> Attendee {
//        attendee.eventId = event.id
//        attendee.userId = user.id
        return Attendee()
    }
    
    func save(attendee: inout Attendee, attendeeDAO: AttendeeDAO = AttendeeDAO()) throws {
        try attendeeDAO.store { id in
            attendeeDAO.id = id as! Int
            attendee.id = id as! Int
        }
    }
}
