//
//  VoteDataHandlerTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 11/16/19.
//

import XCTest

@testable import FebrewaryServerLib

class VoteDataHandlerTests: XCTestCase {

    static var allTests = [
        ("test_voteExists_returnsFalse_ifVoteNotMade", test_voteExists_returnsFalse_ifVoteNotMade),
        ("test_voteExists_returnsTrue_ifVoteAlreadyMade", test_voteExists_returnsTrue_ifVoteAlreadyMade),
        ("test_save_setsIdOnVote", test_save_setsIdOnVote)
    ]
    
    func test_voteExists_returnsFalse_ifVoteNotMade() {
        let exists = VoteDataHandler().voteExists(forEventBeer: 1, byUser: 1, inEvent: 1, voteDAO: MockNoVoteDAO())
        
        XCTAssertFalse(exists)
    }
    
    func test_voteExists_returnsTrue_ifVoteAlreadyMade() {
        let exists = VoteDataHandler().voteExists(forEventBeer: 1, byUser: 1, inEvent: 1, voteDAO: MockSingleVoteDAO())
        
        XCTAssertTrue(exists)
    }

    func test_save_setsIdOnVote() {
        var vote = Vote(eventId: 1, eventBeerId: 1, userId: 1, score: 1)
        let voteDAO = MockNoVoteDAO()
        voteDAO.id = 0
        
        XCTAssertNoThrow(try VoteDataHandler().save(vote: &vote, voteDAO: voteDAO))
        XCTAssertEqual(1, vote.id)
        XCTAssertEqual(1, vote.id)
    }
}
