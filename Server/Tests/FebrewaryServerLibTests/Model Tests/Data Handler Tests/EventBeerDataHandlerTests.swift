//
//  EventBeerDataHandlerTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 11/10/19.
//

import XCTest
@testable import FebrewaryServerLib

class EventBeerDataHandlerTests: XCTestCase {

    static var allTests = [
        ("test_eventBeersFromEventId_returnsEmpty_ifNothingFound", test_eventBeersFromEventId_returnsEmpty_ifNothingFound),
        ("test_eventBeersFromEventId_returnsEventBeers_whenPresentInDatabase", test_eventBeersFromEventId_returnsEventBeers_whenPresentInDatabase),
        ("test_eventBeerExists_returnsFalse_whenEventBeerNotFoundInDatabase", test_eventBeerExists_returnsFalse_whenEventBeerNotFoundInDatabase),
        ("test_eventBeerExists_returnsFalse_whenManyEventBeerFoundInDatabase", test_eventBeerExists_returnsFalse_whenManyEventBeerFoundInDatabase),
        ("test_eventBeerExists_returnsTrue_whenEventBeerFoundInDatabase", test_eventBeerExists_returnsTrue_whenEventBeerFoundInDatabase)
    ]

    func test_eventBeersFromEventId_returnsEmpty_ifNothingFound() {
        let eventBeerDAO = MockNoEventBeerDAO()
        
        let eventBeers = EventBeerDataHandler().eventBeers(fromEventId: 1, eventBeerDAO: eventBeerDAO)
        
        XCTAssertEqual(0, eventBeers.count)
    }
    
    func test_eventBeersFromEventId_returnsEventBeers_whenPresentInDatabase() {
        let eventBeerDAO = MockManyEventBeerDAO()
        let userDataHandler = MockSuccessfulUserDataHandler()
        
        let eventBeers = EventBeerDataHandler().eventBeers(fromEventId: 1, eventBeerDAO: eventBeerDAO, userDataHandler: userDataHandler)
        
        XCTAssertGreaterThan(eventBeers.count, 0)
    }
    
    func test_eventBeerExists_returnsFalse_whenEventBeerNotFoundInDatabase() {
        let eventBeerDAO = MockNoEventBeerDAO()
        
        let exists = EventBeerDataHandler().eventBeerExists(fromEventId: 1, andUserId: 1, eventBeerDAO: eventBeerDAO)
        
        XCTAssertFalse(exists)
    }
    
    func test_eventBeerExists_returnsFalse_whenManyEventBeerFoundInDatabase() {
        let eventBeerDAO = MockManyEventBeerDAO()
        
        let exists = EventBeerDataHandler().eventBeerExists(fromEventId: 1, andUserId: 1, eventBeerDAO: eventBeerDAO)
        
        XCTAssertFalse(exists, "if there are many EventBeers for a single User, that is an error")
    }
    
    func test_eventBeerExists_returnsTrue_whenEventBeerFoundInDatabase() {
        let eventBeerDAO = MockSingleEventBeerDAO()
        
        let exists = EventBeerDataHandler().eventBeerExists(fromEventId: 1, andUserId: 1, eventBeerDAO: eventBeerDAO)
        
        XCTAssertTrue(exists)
    }
    
    func test_saveEventBeer_setsEventBeerId() {
        var eventBeer = try! EventBeer(id: 0,
                                       userId: 1,
                                       beerId: 1,
                                       eventId: 1,
                                       round: 0,
                                       votes: 0,
                                       score: 0,
                                       isBeingPoured: false,
                                       userDataHandler: MockSuccessfulUserDataHandler())
        let eventBeerDAO = MockSingleEventBeerDAO()
        eventBeerDAO.id = 0
        
        XCTAssertNoThrow(try EventBeerDataHandler().save(eventBeer: &eventBeer, eventBeerDAO: eventBeerDAO))
        XCTAssertEqual(1, eventBeer.id)
        XCTAssertEqual(1, eventBeerDAO.id)
    }
    
}
