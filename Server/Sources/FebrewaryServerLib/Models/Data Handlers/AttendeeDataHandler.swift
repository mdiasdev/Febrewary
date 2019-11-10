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
    
    init(id: Int, eventId: Int, eventBeerId: Int, userId: Int) {
        self.id = id
        self.eventId = eventId
        self.eventBeerId = eventBeerId
        self.userId = userId
    }
    
    init(attendeeDAO: AttendeeDAO) {
        self.id = attendeeDAO.id
        self.eventId = attendeeDAO.eventId
        self.eventBeerId = attendeeDAO.eventBeerId
        self.userId = attendeeDAO.userId
    }
}

class AttendeeDataHandler {
    func createAttendee(fromEventId eventId: Int, andUserId userId: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) throws -> Attendee {
        
        attendeeDAO.userId = userId
        attendeeDAO.eventId = eventId
        
        return Attendee(attendeeDAO: attendeeDAO)
    }
    
    func attendee(fromEventId eventId: Int, andUserId userId: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) throws -> Attendee {
        
        try attendeeDAO.find(by: [("userid", userId), ("eventid", eventId)])
        
        guard attendeeDAO.rows().count == 1 else { throw UserNotInvitedError() }
        
        return Attendee(attendeeDAO: attendeeDAO.rows().first!)
    }
    
    func attendees(fromUserId userId: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) throws -> [Attendee] {
        try attendeeDAO.find(by: [("userid", userId)])
        
        guard attendeeDAO.rows().count > 0 else { throw DatabaseError() }
        
        return attendeeDAO.rows().map( { Attendee(attendeeDAO: $0) } )
    }
    
    func attendees(fromEventId eventId: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) -> [Attendee] {
        try? attendeeDAO.find(by: [("eventid", eventId)])
        
        guard attendeeDAO.rows().count > 0 else { return [] }
        
        return attendeeDAO.rows().map( { Attendee(attendeeDAO: $0) } )
    }
    
    func attendeeExists(withId id: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) -> Bool {
        try? attendeeDAO.find(by: [("id", id)])
        
        guard attendeeDAO.rows().count == 1, let attendee = attendeeDAO.rows().first else { return false }
        
        return attendee.id != 0
    }
    
    func attendeeExists(withUserId userId: Int, inEventId eventId: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) -> Bool {
        try? attendeeDAO.find(by: [("userid", userId), ("eventid", eventId)])
        
        guard attendeeDAO.rows().count == 1, let attendee = attendeeDAO.rows().first else { return false }
        
        return attendee.id != 0
    }
    
    func save(attendee: inout Attendee, attendeeDAO: AttendeeDAO = AttendeeDAO()) throws {
        attendeeDAO.userId = attendee.userId
        attendeeDAO.eventId = attendee.eventId
        
        try attendeeDAO.store { id in
            attendeeDAO.id = id as! Int
            attendee.id = id as! Int
        }
    }
}
