//
//  EventsServiceTests.swift
//  FebrewaryTests
//
//  Created by Matthew Dias on 6/29/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import XCTest

@testable import Febrewary

class EventsServiceTests: XCTestCase {
    
    var sut: EventsService!
    var fakeService: FakeServiceClient!

    override func setUp() {
        super.setUp()
        
        fakeService = FakeServiceClient()
        sut = EventsService(client: fakeService)
    }

    override func tearDown() {
        fakeService = nil
        sut = nil
        
        super.tearDown()
    }
    
    func test_getAllEventsForCurrentUser_decodesEvents_fromSuccessfulResponse() {
        fakeService.successFileName = "EventList"
        let completed = expectation(description: "call should finish")
        
        sut.getAllEventsForCurrentUser { result in
            completed.fulfill()
            switch result {
            case .success(let events):
                XCTAssertGreaterThan(events.count, 0)
            case .failure:
                XCTFail("Something went wrong!")
            }
        }
        
        wait(for: [completed], timeout: 1.0)
    }
    
    func test_createEvent_decodesEvent_fromSuccessfulResponse() {
        fakeService.successFileName = "CreateEvent"
        let completed = expectation(description: "call should finish")
        
        sut.createEvent(named: "some event",
                        on: Date(),
                        at: "some address",
                        isPourer: true) { result in
            completed.fulfill()
            switch result {
            case .success(let event):
                XCTAssertNotNil(event)
            case .failure:
                XCTFail("Something went wrong!")
            }
        }
        
        wait(for: [completed], timeout: 1.0)
    }

}
