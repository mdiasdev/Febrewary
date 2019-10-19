//
//  EventDataHandler.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 10/12/19.
//

import Foundation
import PerfectHTTP

struct Event: Codable {
    var id: Int = 0
    var name: String
    var address: String
    var date: String
    var createdBy: Int
    var pourerId: Int = 0
    
    // event state
    var isOver: Bool = false
    var hasStarted: Bool = false
    
    // embedded sub-objects
    var attendees: [Attendee] = []
    var eventBeers: [EventBeer] = []
    
    init(name: String, date: String, address: String, createdBy: Int) {
        self.name = name
        self.address = address
        self.date = date
        self.createdBy = createdBy
    }
    
    fileprivate init(id: Int, eventDAO: EventDAO) throws {
        // FIXME: Make this real
        self = Event(name: "", date: "", address: "", createdBy: 0)
    }
    
    fileprivate init(eventDAO: EventDAO, attendeeDataHandler: AttendeeDataHandler = AttendeeDataHandler(), eventBeerDataHandler: EventBeerDataHandler = EventBeerDataHandler()) {
        self.id = eventDAO.id
        self.name = eventDAO.name
        self.address = eventDAO.address
        self.date = eventDAO.date
        self.createdBy = eventDAO.createdBy
        self.pourerId = eventDAO.pourerId
        self.isOver = eventDAO.isOver
        self.hasStarted = eventDAO.hasStarted
        
        self.attendees = attendeeDataHandler.attendees(fromEventId: eventDAO.id)
        self.eventBeers = eventBeerDataHandler.eventBeers(fromEventId: eventDAO.id)
    }
    
    fileprivate init(request: HTTPRequest, by user: User) throws {
        guard let postBody = try? request.postBodyString?.jsonDecode() as? [String: Any],
              let json = postBody else {
                throw MalformedJSONError()
        }

        guard let name = json["name"] as? String,
              let date = json["date"] as? String,
              let address = json["address"] as? String,
              let isPourer = json["isPourer"] as? Bool else {
                throw MissingPropertyError()
        }
        
        self = Event(name: name, date: date, address: address, createdBy: user.id)
        
        if isPourer {
            self.pourerId = user.id
        }
    }
}

class EventDataHandler {
    func event(from id: Int, eventDAO: EventDAO = EventDAO()) throws -> Event {
        return try Event(id: id, eventDAO: eventDAO)
    }
    
    func event(from request: HTTPRequest, by user: User) throws -> Event {
        return try Event(request: request, by: user)
    }
    
    func events(fromAttendees attendees: [Attendee], eventDAO: EventDAO = EventDAO()) throws -> [Event] {
        let query = "id IN (\(attendees.compactMap { "\($0.eventId)" }.toString()))"
        
        try eventDAO.search(whereClause: query, params: [], orderby: ["id"])
        
        return eventDAO.rows().map( { Event(eventDAO: $0) } )
    }
    
    func save(event: inout Event, eventDAO: EventDAO = EventDAO()) throws {
        eventDAO.id = event.id
        eventDAO.name = event.name
        eventDAO.address = event.address
        eventDAO.date = event.date
        eventDAO.createdBy = event.createdBy
        eventDAO.pourerId = event.pourerId
        eventDAO.isOver = event.isOver
        eventDAO.hasStarted = event.hasStarted
        
        try eventDAO.store { id in
            eventDAO.id = id as! Int
            event.id = id as! Int
        }
    }
    
    func json(from event: Event) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(event)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw DatabaseError()
        }
        
        return jsonString
    }
    
    func jsonArray(from events: [Event]) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(events)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw DatabaseError()
        }
        
        return jsonString
    }
}
