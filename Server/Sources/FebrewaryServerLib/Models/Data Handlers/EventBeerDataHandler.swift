//
//  EventBeerDataHandler.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 10/19/19.
//

import Foundation

struct EventBeer: Codable {
    var id: Int = 0
    var userId: Int
    var beerId: Int
    var eventId: Int
    var round: Int = 0
    var votes: Int = 0
    var score: Int = 0
    var isBeingPoured: Bool = false
    
    // FIXME: add embedded beer object
    var user: User
//    var beer: Beer
    
    init(id: Int = 0, userId: Int, beerId: Int, eventId: Int, round: Int = 0, votes: Int =  0, score: Int = 0, isBeingPoured: Bool = false, userDataHander: UserDataHandler = UserDataHandler(), eventDataHandler: EventDataHandler = EventDataHandler()) throws {
        
        self.id = id
        self.userId = userId
        self.beerId = beerId
        self.eventId = eventId
        self.round = round
        self.votes = votes
        self.score = score
        self.isBeingPoured = isBeingPoured
        
        self.user = try userDataHander.user(from: userId)
    }
    
    fileprivate init(eventBeerDAO: EventBeerDAO) throws {
        self = try EventBeer(id: eventBeerDAO.id,
                             userId: eventBeerDAO.userId,
                             beerId: eventBeerDAO.beerId,
                             eventId: eventBeerDAO.eventId,
                             round: eventBeerDAO.round,
                             votes: eventBeerDAO.votes,
                             score: eventBeerDAO.score,
                             isBeingPoured: eventBeerDAO.isBeingPoured)
    }
}

class EventBeerDataHandler {
    func eventBeers(fromEventId eventId: Int, eventBeerDAO: EventBeerDAO = EventBeerDAO()) -> [EventBeer] {
        
        try? eventBeerDAO.find(by: [("eventid", eventId)])
        
        return eventBeerDAO.rows().compactMap({ try? EventBeer(eventBeerDAO: $0) })
    }
    
    func eventBeerExists(fromEventId eventId: Int, andUserId userId: Int, eventBeerDAO: EventBeerDAO = EventBeerDAO()) -> Bool {
        
        try? eventBeerDAO.find(by: [
            ("userId", userId),
            ("eventId", eventId)
        ])
        
        guard eventBeerDAO.rows().count == 1, let eventBeer = eventBeerDAO.rows().first else { return false }
        
        return eventBeer.id != 0
    }
    
    func save(eventBeer: inout EventBeer, eventBeerDAO: EventBeerDAO = EventBeerDAO()) throws {
        try eventBeerDAO.store { id in
            eventBeerDAO.id = id as! Int
            eventBeer.id = id as! Int
        }
    }
}
