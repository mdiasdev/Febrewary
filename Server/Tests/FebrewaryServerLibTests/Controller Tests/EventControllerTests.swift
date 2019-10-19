//
//  EventControllerTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 10/8/19.
//

import XCTest
import PerfectHTTP

@testable import FebrewaryServerLib

class EventControllerTests: XCTestCase {

    static var allTests = [
        ("test_createEvent_respondsWithMalformedJSONError_whenNoPostBody", test_createEvent_respondsWithMalformedJSONError_whenNoPostBody),
        ("test_createEvent_respondsWithMissingPropertyError_whenMissingRequiredProperty", test_createEvent_respondsWithMissingPropertyError_whenMissingRequiredProperty),
        ("test_createEvent_createsAttendee_whenCreatingEvent", test_createEvent_createsAttendee_whenCreatingEvent),
        ("test_createEvent_doesNotCreateAttendee_whenFailedToCreateEvent", test_createEvent_doesNotCreateAttendee_whenFailedToCreateEvent),
    ]

    func test_createEvent_respondsWithMalformedJSONError_whenNoPostBody(){
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        let spyResponse = SpyResponse()
        let fakeUserDataHandler = FakeUserDataHander()
        let expectedString = " {\n     title: Malformed Request JSON,\n     message: Unable to parse JSON.,\n     code: 400\n }"
        
        EventController().createEvent(request: fakeRequest, response: spyResponse, userDataHandler: fakeUserDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_createEvent_respondsWithMissingPropertyError_whenMissingRequiredProperty(){
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = getCreateEventPostBodyMissingName()
        let spyResponse = SpyResponse()
        let fakeUserDataHandler = FakeUserDataHander()
        let expectedString = " {\n     title: Missing request property,\n     message: One or more properties are missing.,\n     code: 400\n }"
        
        EventController().createEvent(request: fakeRequest, response: spyResponse, userDataHandler: fakeUserDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    // MARK: - Create Event
    func test_createEvent_createsAttendee_whenCreatingEvent() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = getCreateEventPostBodyIsPourer()
        let spyResponse = SpyResponse()
        let spyAttendeeDataHandler = SpyAttendeeDataHandler()
        let fakeUserDataHandler = FakeUserDataHander()
        let fakeEventDataHandler = FakeEventDataHandler()
        
        EventController().createEvent(request: fakeRequest, response: spyResponse, userDataHandler: fakeUserDataHandler, eventDataHandler: fakeEventDataHandler, attendeeDataHandler: spyAttendeeDataHandler)
        
        XCTAssertTrue(spyAttendeeDataHandler.didCallSave)
    }
    
    func test_createEvent_doesNotCreateAttendee_whenFailedToCreateEvent() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = getCreateEventPostBodyIsPourer()
        let spyResponse = SpyResponse()
        let spyAttendeeDataHandler = SpyAttendeeDataHandler()
        let fakeUserDataHandler = FakeUserDataHander()
        let fakeEventDataHandler = FakeEventDataHandler()
        fakeEventDataHandler.id = 0
        
        EventController().createEvent(request: fakeRequest, response: spyResponse, userDataHandler: fakeUserDataHandler, eventDataHandler: fakeEventDataHandler, attendeeDataHandler: spyAttendeeDataHandler)
        
        XCTAssertFalse(spyAttendeeDataHandler.didCallSave)
    }
    
    // MARK: - Get Event For Current User
    func test_getEventForUser_respondsEmpty_whenNoAttendeesFound() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        let spyResponse = SpyResponse()
        let fakeUserDataHandler = FakeUserDataHander()
        let fakeAttendeeDataHandler = FakeNoneAttendeeDataHandler()
        
        EventController().getEventForUser(request: fakeRequest,
                                          response: spyResponse,
                                          userDataHandler: fakeUserDataHandler,
                                          attendeeDataHandler: fakeAttendeeDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, "[]")
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_getEventForUser_respondsWithEventsJson_whenUserHaveEvents() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        let spyResponse = SpyResponse()
        let fakeUserDataHandler = FakeUserDataHander()
        let fakeAttendeeDataHandler = FakeAttendeeDataHandler()
        let fakeEventDataHandler = FakeEventDataHandler()
        let expectedString = "[\n  {\n    \"isOver\" : false,\n    \"pourerId\" : 0,\n    \"address\" : \"here\",\n    \"id\" : 0,\n    \"date\" : \"tomorrow\",\n    \"hasStarted\" : false,\n    \"createdBy\" : 1,\n    \"eventBeers\" : [\n\n    ],\n    \"name\" : \"Something fun\",\n    \"attendees\" : [\n\n    ]\n  },\n  {\n    \"isOver\" : false,\n    \"pourerId\" : 0,\n    \"address\" : \"there\",\n    \"id\" : 0,\n    \"date\" : \"the next day\",\n    \"hasStarted\" : false,\n    \"createdBy\" : 1,\n    \"eventBeers\" : [\n\n    ],\n    \"name\" : \"Something else fun\",\n    \"attendees\" : [\n\n    ]\n  }\n]"
        
        EventController().getEventForUser(request: fakeRequest,
                                          response: spyResponse,
                                          userDataHandler: fakeUserDataHandler,
                                          eventDataHandler: fakeEventDataHandler,
                                          attendeeDataHandler: fakeAttendeeDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    // MARK: - Test Helpers
    func getCreateEventPostBodyMissingName() -> String {
        return """
        {
            "date": "March 1st",
            "address": "home",
            "isPourer": false
        }
        """
    }
    
    func getCreateEventPostBodyIsPourer() -> String {
        return """
        {
            "name": "Fun Times",
            "date": "March 1st",
            "address": "home",
            "isPourer": true
        }
        """
    }
    
    func getCreateEventPostBodyIsNotPourer() -> String {
        return """
        {
            "name": "Fun Times",
            "date": "March 1st",
            "address": "home",
            "isPourer": false
        }
        """
    }
    
    // MARK: - Test Doubles
    class SpyAttendeeDataHandler: AttendeeDataHandler {
        var didCallSave = false
        
        override func attendee(fromEventId eventId: Int, andUserId userId: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) throws -> Attendee {
            return Attendee(attendeeDAO: MockSingleAttendeeDAO())
        }
        override func save(attendee: inout Attendee, attendeeDAO: AttendeeDAO = AttendeeDAO()) throws {
            didCallSave = true
        }
    }
    
    class FakeUserDataHander: UserDataHandler {
        override func user(from request: HTTPRequest, userDAO: UserDAO = UserDAO()) throws -> User {
            return User(id: 1, name: "Matt", email: "my@email.com")
        }
    }
    
    class FakeEventDataHandler: EventDataHandler {
        var id = 1
        
        override func event(from request: HTTPRequest, by user: User) throws -> Event {
            return Event(name: "Fun Times", date: "Tomorrow", address: "my place", createdBy: 1)
        }
        
        override func events(fromAttendees attendees: [Attendee], eventDAO: EventDAO = EventDAO()) throws -> [Event] {
            return [
                Event(name: "Something fun", date: "tomorrow", address: "here", createdBy: 1),
                Event(name: "Something else fun", date: "the next day", address: "there", createdBy: 1)
            ]
        }
        
        override func save(event: inout Event, eventDAO: EventDAO = EventDAO()) throws {
            event.id = id
        }
    }
    
    class FakeNoneAttendeeDataHandler: AttendeeDataHandler {
        override func attendees(fromUserId userId: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) throws -> [Attendee] {
            return []
        }
    }
    
    class FakeAttendeeDataHandler: AttendeeDataHandler {
        override func attendees(fromUserId userId: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) throws -> [Attendee] {
            return [Attendee(id: 1, eventId: 1, eventBeerId: 1, userId: 1)]
        }
    }
}
