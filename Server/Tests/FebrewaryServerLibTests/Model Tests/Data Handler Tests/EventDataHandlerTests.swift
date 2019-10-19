//
//  EventDataHandlerTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 10/12/19.
//

import XCTest

@testable import FebrewaryServerLib

class EventDataHandlerTests: XCTestCase {

    static var allTests = [
        ("test_eventFromRequest_returnsEvent_whenAllPropertiesPresent", test_eventFromRequest_returnsEvent_whenAllPropertiesPresent),
        ("test_eventFromRequest_doesNotThrow_whenAllPropertiesPresent", test_eventFromRequest_doesNotThrow_whenAllPropertiesPresent),
        ("test_eventFromRequest_throwsMalformedJSONError_whenNoPostBody", test_eventFromRequest_throwsMalformedJSONError_whenNoPostBody),
        ("test_jsonFromEvent_returnsEventAsJSONString", test_jsonFromEvent_returnsEventAsJSONString),
        ("test_save_setsEventID_afterSaving", test_save_setsEventID_afterSaving),
        ("test_eventsFromAttendees_returnsArrayOfEvents_whenFoundInDatabase", test_eventsFromAttendees_returnsArrayOfEvents_whenFoundInDatabase),
        ("test_jsonArrayFromEvents_returnsEventsAsJSONString", test_jsonArrayFromEvents_returnsEventsAsJSONString)
    ]

    func test_eventFromRequest_returnsEvent_whenAllPropertiesPresent() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = EventControllerTests().getCreateEventPostBodyIsPourer()
        let user = User(id: 1, name: "Matt", email: "my@email.com")
        
        let event = try! EventDataHandler().event(from: fakeRequest, by: user)
        
        XCTAssertEqual(event.createdBy, user.id)
    }
    
    func test_eventFromRequest_doesNotThrow_whenAllPropertiesPresent() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = EventControllerTests().getCreateEventPostBodyIsPourer()
        let user = User(id: 1, name: "Matt", email: "my@email.com")
        
        XCTAssertNoThrow(try EventDataHandler().event(from: fakeRequest, by: user))
    }
    
    func test_eventFromRequest_throwsMalformedJSONError_whenNoPostBody() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        let user = User(id: 1, name: "Matt", email: "my@email.com")
        
        XCTAssertThrowsError(try EventDataHandler().event(from: fakeRequest, by: user), "error not thrown") { error in
            XCTAssertTrue(error is MalformedJSONError)
        }
    }
    
    func test_eventFromRequest_throwsMissingPropertyError_whenMissingAProperty() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = EventControllerTests().getCreateEventPostBodyMissingName()
        let user = User(id: 1, name: "Matt", email: "my@email.com")
        
        XCTAssertThrowsError(try EventDataHandler().event(from: fakeRequest, by: user), "error not thrown") { error in
            XCTAssertTrue(error is MissingPropertyError)
        }
    }
    
    // MARK: - events from attendees
    func test_eventsFromAttendees_returnsArrayOfEvents_whenFoundInDatabase() {
        let attendees = [Attendee(id: 1, eventId: 1, eventBeerId: 1, userId: 1)]
        let mockEventDAO = MockEventDAO()
        
        let expectedEvents = try! EventDataHandler().events(fromAttendees: attendees, eventDAO: mockEventDAO)
        
        XCTAssertEqual(2, expectedEvents.count)
    }
    
    // MARK: - Save
    func test_save_setsEventID_afterSaving() {
        var event = Event(name: "Fun Times", date: "tomorrow", address: "my home", createdBy: 1)
        let fakeEventDAO = FakeEventDAO()
        
        try! EventDataHandler().save(event: &event, eventDAO: fakeEventDAO)
        
        XCTAssertEqual(event.id, fakeEventDAO.id)
        XCTAssertGreaterThan(event.id, 0)
    }
    
    // MARK: - JSON Builders
    func test_jsonFromEvent_returnsEventAsJSONString() {
        let event = Event(name: "Fun Times", date: "tomorrow", address: "my home", createdBy: 1)
        let expected = "{\n  \"isOver\" : false,\n  \"pourerId\" : 0,\n  \"address\" : \"my home\",\n  \"id\" : 0,\n  \"date\" : \"tomorrow\",\n  \"hasStarted\" : false,\n  \"createdBy\" : 1,\n  \"eventBeers\" : [\n\n  ],\n  \"name\" : \"Fun Times\",\n  \"attendees\" : [\n\n  ]\n}"
        
        let actual = try! EventDataHandler().json(from: event)
        
        XCTAssertEqual(expected, actual)
    }
    
    func test_jsonArrayFromEvents_returnsEventsAsJSONString() {
        let events = [
            Event(name: "Fun Times", date: "tomorrow", address: "my home", createdBy: 1),
            Event(name: "More Fun Times", date: "the day after tomorrow", address: "my home", createdBy: 1)
        ]
        let expected = "[\n  {\n    \"isOver\" : false,\n    \"pourerId\" : 0,\n    \"address\" : \"my home\",\n    \"id\" : 0,\n    \"date\" : \"tomorrow\",\n    \"hasStarted\" : false,\n    \"createdBy\" : 1,\n    \"eventBeers\" : [\n\n    ],\n    \"name\" : \"Fun Times\",\n    \"attendees\" : [\n\n    ]\n  },\n  {\n    \"isOver\" : false,\n    \"pourerId\" : 0,\n    \"address\" : \"my home\",\n    \"id\" : 0,\n    \"date\" : \"the day after tomorrow\",\n    \"hasStarted\" : false,\n    \"createdBy\" : 1,\n    \"eventBeers\" : [\n\n    ],\n    \"name\" : \"More Fun Times\",\n    \"attendees\" : [\n\n    ]\n  }\n]"
        
        let actual = try! EventDataHandler().jsonArray(from: events)
        
        XCTAssertEqual(expected, actual)
    }
}

class FakeEventDAO: EventDAO {
    override func store(set: (Any) -> Void) throws {
        set(1)
    }
}
