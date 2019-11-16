//
//  VoteDataHander.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 11/16/19.
//

import Foundation

struct Vote: Codable {
    var id: Int = 0
    var eventId: Int // the event the user is at
    var eventBeerId: Int // beer the user is voting on
    var userId: Int // user whose vote it is
    var score: Int
}

class VoteDataHandler {
    func voteExists(forEventBeer eventBeerId: Int, byUser userId: Int, inEvent eventId: Int, voteDAO: VoteDAO = VoteDAO()) -> Bool {
        try? voteDAO.find(by: [("eventid", eventId), ("eventbeerid", eventBeerId), ("userid", userId)])
        
        guard let vote = voteDAO.rows().first else { return false }

        return vote.id > 0
    }
    
    func save(vote: inout Vote, voteDAO: VoteDAO = VoteDAO()) throws {
        voteDAO.eventId = vote.eventId
        voteDAO.eventBeerId = vote.eventBeerId
        voteDAO.userId = vote.userId
        voteDAO.score = vote.score
        
        try voteDAO.save(set: { id in
            vote.id = id as! Int
            voteDAO.id = id as! Int
        })
    }
}
