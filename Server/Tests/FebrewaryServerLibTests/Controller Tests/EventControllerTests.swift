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
        ("test_getEventForUser_respondsEmpty_whenNoAttendeesFound", test_getEventForUser_respondsEmpty_whenNoAttendeesFound),
        ("test_getEventForUser_respondsWithEventsJson_whenUserHaveEvents", test_getEventForUser_respondsWithEventsJson_whenUserHaveEvents),
        ("test_addEventBeer_respondsMalfromJSONError_whenMissingPostBody", test_addEventBeer_respondsMalfromJSONError_whenMissingPostBody),
        ("test_addEventBeer_respondsMissingPropertyError_whenPostBodyMissingBeerId", test_addEventBeer_respondsMissingPropertyError_whenPostBodyMissingBeerId),
        ("test_addEventBeer_respondsUserNotInvitedError_whenCurrentUserNotInEvent", test_addEventBeer_respondsUserNotInvitedError_whenCurrentUserNotInEvent),
        ("test_addEventBeer_respondsEventBeerExistsError_whenCurrentUserHasEventBeerAlready", test_addEventBeer_respondsEventBeerExistsError_whenCurrentUserHasEventBeerAlready),
        ("test_addEventBeer_respondsCreated_whenAllIsSuccessful", test_addEventBeer_respondsCreated_whenAllIsSuccessful),
        ("test_addAttendee_respondsMalfromJSONError_whenMissingPostBody", test_addAttendee_respondsMalfromJSONError_whenMissingPostBody),
        ("test_addAttendee_respondsMissingPropertyError_whenPostBodyMissingUserId", test_addAttendee_respondsMissingPropertyError_whenPostBodyMissingUserId),
        ("test_addAttendee_respondsMissingPropertyError_whenPostBodyMissingIsPourer", test_addAttendee_respondsMissingPropertyError_whenPostBodyMissingIsPourer),
        ("test_addAttendee_savesPourer_whenAttendeeIsPourer", test_addAttendee_savesPourer_whenAttendeeIsPourer),
        ("test_addAttendee_respondsWithPourerConflictError_whenPourerIsAlreadyAssigned", test_addAttendee_respondsWithPourerConflictError_whenPourerIsAlreadyAssigned),
        ("test_addAttendee_respondsCreated_whenAllIsSuccessful", test_addAttendee_respondsCreated_whenAllIsSuccessful),
        ("test_pourEventBeer_respondsUnauthorizedPourerError_whenCurrentUserIsNotPourer", test_pourEventBeer_respondsUnauthorizedPourerError_whenCurrentUserIsNotPourer),
        ("test_pourEventBeer_respondsNotEnoughAttendeesError_whenFewerThanTwoAttendees", test_pourEventBeer_respondsNotEnoughAttendeesError_whenFewerThanTwoAttendees),
        ("test_pourEventBeer_setsHasStarted_whenEventHasNotStarted", test_pourEventBeer_setsHasStarted_whenEventHasNotStarted),
        ("test_pourEventBeer_respondsVotingIncompleteError_whenNotAllAttendeesHaveVoted", test_pourEventBeer_respondsVotingIncompleteError_whenNotAllAttendeesHaveVoted),
        ("test_pourEventBeer_setsIsBeingPoured_whenAllVotesIn", test_pourEventBeer_setsIsBeingPoured_whenAllVotesIn),
        ("test_pourEventBeer_setsIsBeingPoured_whenPourIsForced", test_pourEventBeer_setsIsBeingPoured_whenPourIsForced),
        ("test_pourEventBeer_responsedNoContent_whenNoBeersLeftToPour", test_pourEventBeer_responsedNoContent_whenNoBeersLeftToPour)
    ]

    // MARK: - Create Event
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
    
    // MARK: - Add Beer to Event
    func test_addEventBeer_respondsMalfromJSONError_whenMissingPostBody() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        let spyResponse = SpyResponse()
        let expectedString = " {\n     title: Malformed Request JSON,\n     message: Unable to parse JSON.,\n     code: 400\n }"
        
        EventController().addEventBeer(request: fakeRequest, response: spyResponse)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_addEventBeer_respondsMissingPropertyError_whenPostBodyMissingBeerId() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = "{}"
        let spyResponse = SpyResponse()
        let expectedString = " {\n     title: Missing request property,\n     message: One or more properties are missing.,\n     code: 400\n }"
        
        EventController().addEventBeer(request: fakeRequest, response: spyResponse)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_addEventBeer_respondsUserNotInvitedError_whenCurrentUserNotInEvent() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = "{ \"beerId\": 1 }"
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let eventDataHandler = FakeEventDataHandler()
        let attendeeDataHandler = FakeNoneAttendeeDataHandler()
        let expectedString = " {\n     title: User Not Invited,\n     message: This user has not yet been invited to this event.,\n     code: 404\n }"
        
        EventController().addEventBeer(request: fakeRequest, response: spyResponse, userDataHandler: userDataHandler, eventDataHandler: eventDataHandler, attendeeDataHandler: attendeeDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_addEventBeer_respondsEventBeerExistsError_whenCurrentUserHasEventBeerAlready() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = "{ \"beerId\": 1 }"
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let eventDataHandler = FakeEventDataHandler()
        let attendeeDataHandler = FakeAttendeeDataHandler()
        let eventBeerDataHandler = FakeEventBeerDataHandler()
        let expectedString = " {\n     title: Cannot Add Beer to Event,\n     message: This User has already added a Beer to this Event.,\n     code: 403\n }"
        
        EventController().addEventBeer(request: fakeRequest, response: spyResponse, userDataHandler: userDataHandler, eventDataHandler: eventDataHandler, eventBeerDataHandler: eventBeerDataHandler, attendeeDataHandler: attendeeDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_addEventBeer_respondsCreated_whenAllIsSuccessful() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = "{ \"beerId\": 1 }"
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let eventDataHandler = FakeEventDataHandler()
        let attendeeDataHandler = FakeAttendeeDataHandler()
        let eventBeerDataHandler = FakeNoEventBeerDataHandler()
        let expectedString = ""
        
        EventController().addEventBeer(request: fakeRequest, response: spyResponse, userDataHandler: userDataHandler, eventDataHandler: eventDataHandler, eventBeerDataHandler: eventBeerDataHandler, attendeeDataHandler: attendeeDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
            XCTAssertEqual(spyResponse.status.code, 201)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    // MARK: - Add Attendee
    func test_addAttendee_respondsMalfromJSONError_whenMissingPostBody() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        let spyResponse = SpyResponse()
        let expectedString = " {\n     title: Malformed Request JSON,\n     message: Unable to parse JSON.,\n     code: 400\n }"
        
        EventController().addAttendee(request: fakeRequest, response: spyResponse)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_addAttendee_respondsMissingPropertyError_whenPostBodyEmpty() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = "{}"
        let spyResponse = SpyResponse()
        let expectedString = " {\n     title: Missing request property,\n     message: One or more properties are missing.,\n     code: 400\n }"
        
        EventController().addAttendee(request: fakeRequest, response: spyResponse)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_addAttendee_respondsMissingPropertyError_whenPostBodyMissingUserId() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = "{\"isPourer\": true}"
        let spyResponse = SpyResponse()
        let expectedString = " {\n     title: Missing request property,\n     message: One or more properties are missing.,\n     code: 400\n }"
        
        EventController().addAttendee(request: fakeRequest, response: spyResponse)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_addAttendee_respondsMissingPropertyError_whenPostBodyMissingIsPourer() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = "{\"userId\": 1}"
        let spyResponse = SpyResponse()
        let expectedString = " {\n     title: Missing request property,\n     message: One or more properties are missing.,\n     code: 400\n }"
        
        EventController().addAttendee(request: fakeRequest, response: spyResponse)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_addAttendee_savesPourer_whenAttendeeIsPourer() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = "{ \"userId\": 1, \"isPourer\": true }"
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let eventDataHandler = FakeEventDataHandler()
        let attendeeDataHandler = FakeAttendeeDataHandler()

        EventController().addAttendee(request: fakeRequest,
                                      response: spyResponse,
                                      userDataHandler: userDataHandler,
                                      eventDataHandler: eventDataHandler,
                                      attendeeDataHandler: attendeeDataHandler)
        
        XCTAssertTrue(eventDataHandler.didSave)
    }
    
    func test_addAttendee_respondsWithPourerConflictError_whenPourerIsAlreadyAssigned() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = "{ \"userId\": 1, \"isPourer\": true }"
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let eventDataHandler = FakeEventDataHandler()
        eventDataHandler.pourerIdOverride = 1
        let attendeeDataHandler = FakeAttendeeDataHandler()
        let expectedString = " {\n     title: Pourer Conflict,\n     message: This Event already has a designated Pourer.,\n     code: 409\n }"

        EventController().addAttendee(request: fakeRequest,
                                      response: spyResponse,
                                      userDataHandler: userDataHandler,
                                      eventDataHandler: eventDataHandler,
                                      attendeeDataHandler: attendeeDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_addAttendee_respondsCreated_whenAllIsSuccessful() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.postBodyString = "{ \"userId\": 1, \"isPourer\": false }"
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let eventDataHandler = FakeEventDataHandler()
        let attendeeDataHandler = FakeAttendeeDataHandler()
        let expectedString = ""
        
        EventController().addAttendee(request: fakeRequest, response: spyResponse, userDataHandler: userDataHandler, eventDataHandler: eventDataHandler,  attendeeDataHandler: attendeeDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
            XCTAssertEqual(spyResponse.status.code, 201)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    // MARK: - Pour Event Beer
    func test_pourEventBeer_respondsUnauthorizedPourerError_whenCurrentUserIsNotPourer() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let eventDataHandler = FakeEventDataHandler()
        eventDataHandler.pourerIdOverride = 2
        let attendeeDataHandler = FakeAttendeeDataHandler()
        let eventBeerDataHandler = FakeEventBeerDataHandler()
        let expectedString = " {\n     title: Unauthorized Pourer,\n     message: You are not allowed to pour beers at this event.,\n     code: 401\n }"
        
        EventController().pourEventBeer(request: fakeRequest,
                                        response: spyResponse,
                                        eventDataHandler: eventDataHandler,
                                        userDataHandler: userDataHandler,
                                        eventBeerDataHandler: eventBeerDataHandler,
                                        attendeeDataHandler: attendeeDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_pourEventBeer_respondsNotEnoughAttendeesError_whenFewerThanTwoAttendees() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let eventDataHandler = FakeEventDataHandler()
        eventDataHandler.pourerIdOverride = 1
        let attendeeDataHandler = FakeNoneAttendeeDataHandler()
        let eventBeerDataHandler = FakeEventBeerDataHandler()
        let expectedString = " {\n     title: Not Enough Attendees,\n     message: And Event must have at least two Attendees before it can be started.,\n     code: 400\n }"
        
        EventController().pourEventBeer(request: fakeRequest,
                                        response: spyResponse,
                                        eventDataHandler: eventDataHandler,
                                        userDataHandler: userDataHandler,
                                        eventBeerDataHandler: eventBeerDataHandler,
                                        attendeeDataHandler: attendeeDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_pourEventBeer_setsHasStarted_whenEventHasNotStarted() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let eventDataHandler = FakeEventDataHandler()
        eventDataHandler.pourerIdOverride = 1
        let attendeeDataHandler = FakeAttendeeDataHandler()
        let eventBeerDataHandler = FakeNoEventBeerDataHandler()
        
        EventController().pourEventBeer(request: fakeRequest,
                                        response: spyResponse,
                                        eventDataHandler: eventDataHandler,
                                        userDataHandler: userDataHandler,
                                        eventBeerDataHandler: eventBeerDataHandler,
                                        attendeeDataHandler: attendeeDataHandler)
        
        XCTAssertTrue(eventDataHandler.didSave)
    }
    
    func test_pourEventBeer_respondsVotingIncompleteError_whenNotAllAttendeesHaveVoted() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.queryParams = [("force", "false")]
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let eventDataHandler = FakeEventDataHandler()
        eventDataHandler.pourerIdOverride = 1
        let attendeeDataHandler = FakeAttendeeDataHandler()
        let eventBeerDataHandler = FakeEventBeerDataHandler()
        eventBeerDataHandler.voteCountOverride = 0
        let expectedString = " {\n     title: Voting Incomplete,\n     message: Warning: not all votes are in. You can force the roudn to end if you still want to proceed.,\n     code: 412\n }"
        
        EventController().pourEventBeer(request: fakeRequest,
                                        response: spyResponse,
                                        eventDataHandler: eventDataHandler,
                                        userDataHandler: userDataHandler,
                                        eventBeerDataHandler: eventBeerDataHandler,
                                        attendeeDataHandler: attendeeDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_pourEventBeer_setsIsBeingPoured_whenAllVotesIn() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.queryParams = [("force", "false")]
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let eventDataHandler = FakeEventDataHandler()
        eventDataHandler.pourerIdOverride = 1
        let attendeeDataHandler = FakeAttendeeDataHandler()
        let eventBeerDataHandler = FakeEventBeerDataHandler()
        eventBeerDataHandler.isBeingPouredOverride = true
        eventBeerDataHandler.voteCountOverride = 1
        
        EventController().pourEventBeer(request: fakeRequest,
                                        response: spyResponse,
                                        eventDataHandler: eventDataHandler,
                                        userDataHandler: userDataHandler,
                                        eventBeerDataHandler: eventBeerDataHandler,
                                        attendeeDataHandler: attendeeDataHandler)
        
        XCTAssertTrue(eventBeerDataHandler.didSave)
    }
    
    func test_pourEventBeer_setsIsBeingPoured_whenPourIsForced() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.queryParams = [("force", "true")]
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let eventDataHandler = FakeEventDataHandler()
        eventDataHandler.pourerIdOverride = 1
        let attendeeDataHandler = FakeAttendeeDataHandler()
        let eventBeerDataHandler = FakeEventBeerDataHandler()
        eventBeerDataHandler.isBeingPouredOverride = true
        eventBeerDataHandler.voteCountOverride = 0
        
        EventController().pourEventBeer(request: fakeRequest,
                                        response: spyResponse,
                                        eventDataHandler: eventDataHandler,
                                        userDataHandler: userDataHandler,
                                        eventBeerDataHandler: eventBeerDataHandler,
                                        attendeeDataHandler: attendeeDataHandler)
        
        XCTAssertTrue(eventBeerDataHandler.didSave)
    }
    
    func test_pourEventBeer_responsedNoContent_whenNoBeersLeftToPour() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let eventDataHandler = FakeEventDataHandler()
        eventDataHandler.pourerIdOverride = 1
        let attendeeDataHandler = FakeAttendeeDataHandler()
        let eventBeerDataHandler = FakeEventBeerDataHandler()
        eventBeerDataHandler.isBeingPouredOverride = true
        eventBeerDataHandler.voteCountOverride = 1
        eventBeerDataHandler.roundOverride = 2
        let spyEventController = SpyEventController()
        
        spyEventController.pourEventBeer(request: fakeRequest,
                                            response: spyResponse,
                                            eventDataHandler: eventDataHandler,
                                            userDataHandler: userDataHandler,
                                            eventBeerDataHandler: eventBeerDataHandler,
                                            attendeeDataHandler: attendeeDataHandler)
        
        XCTAssertTrue(spyEventController.didEnd)
        XCTAssertEqual(spyResponse.status.code, 204)
    }
    
    func test_pourEventBeer_respondsWithEventBeer_whenAllChecksPass() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.queryParams = [("force", "true")]
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let eventDataHandler = FakeEventDataHandler()
        eventDataHandler.pourerIdOverride = 1
        let attendeeDataHandler = FakeAttendeeDataHandler()
        let eventBeerDataHandler = FakeEventBeerDataHandler()
        eventBeerDataHandler.isBeingPouredOverride = true
        eventBeerDataHandler.voteCountOverride = 0
        let expectedString = "{\n  \"beerId\" : 2,\n  \"score\" : 0,\n  \"round\" : 2,\n  \"id\" : 2,\n  \"userId\" : 2,\n  \"votes\" : 0,\n  \"eventId\" : 1,\n  \"isBeingPoured\" : true,\n  \"user\" : {\n    \"id\" : 1,\n    \"name\" : \"Matt\",\n    \"email\" : \"my@email.com\"\n  }\n}"
        
        EventController().pourEventBeer(request: fakeRequest,
                                        response: spyResponse,
                                        eventDataHandler: eventDataHandler,
                                        userDataHandler: userDataHandler,
                                        eventBeerDataHandler: eventBeerDataHandler,
                                        attendeeDataHandler: attendeeDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    // MARK: -
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
        
        override func user(from id: Int, userDAO: UserDAO = UserDAO()) throws -> User {
            return User(id: 1, name: "Matt", email: "my@email.com")
        }
    }
    
    class FakeEventDataHandler: EventDataHandler {
        var id = 1
        var pourerIdOverride = 0
        var didSave = false
        
        override func event(from request: HTTPRequest, by user: User) throws -> Event {
            return Event(name: "Fun Times", date: "Tomorrow", address: "my place", createdBy: 1)
        }
        
        override func event(from request: HTTPRequest, eventDAO: EventDAO = EventDAO()) throws -> Event {
            return Event(name: "Fun Times", date: "Tomorrow", address: "my place", createdBy: 1, pourerId: pourerIdOverride)
        }
        
        override func events(fromAttendees attendees: [Attendee], eventDAO: EventDAO = EventDAO()) throws -> [Event] {
            return [
                Event(name: "Something fun", date: "tomorrow", address: "here", createdBy: 1),
                Event(name: "Something else fun", date: "the next day", address: "there", createdBy: 1)
            ]
        }
        
        override func save(event: inout Event, eventDAO: EventDAO = EventDAO()) throws {
            event.id = id
            didSave = true
        }
    }
    
    class FakeNoneAttendeeDataHandler: AttendeeDataHandler {
        override func attendees(fromUserId userId: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) throws -> [Attendee] {
            return []
        }
        
        override func attendeeExists(withId id: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) -> Bool {
            return false
        }
    }
    
    class FakeAttendeeDataHandler: AttendeeDataHandler {
        override func attendeeExists(withId id: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) -> Bool {
            return true
        }
        
        override func attendeeExists(withUserId userId: Int, inEventId eventId: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) -> Bool {
            return true
        }
        
        override func attendees(fromUserId userId: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) throws -> [Attendee] {
            return [Attendee(id: 1, eventId: 1, eventBeerId: 1, userId: 1)]
        }
        
        override func attendee(fromEventId eventId: Int, andUserId userId: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) throws -> Attendee {
            return Attendee(id: 1, eventId: 1, eventBeerId: 1, userId: 1)
        }
        
        override func save(attendee: inout Attendee, attendeeDAO: AttendeeDAO = AttendeeDAO()) throws {
            // no-op
        }
        
        override func attendees(fromEventId eventId: Int, attendeeDAO: AttendeeDAO = AttendeeDAO()) -> [Attendee] {
            return [Attendee(id: 1, eventId: 1, eventBeerId: 1, userId: 1),
                    Attendee(id: 2, eventId: 2, eventBeerId: 2, userId: 2)]
        }
    }
    
    class FakeEventBeerDataHandler: EventBeerDataHandler {
        var isBeingPouredOverride = true
        var voteCountOverride = 0
        var roundOverride = 0
        
        var didSave = false
        
        override func eventBeerExists(fromEventId eventId: Int, andUserId userId: Int, eventBeerDAO: EventBeerDAO = EventBeerDAO()) -> Bool {
            return true
        }
        
        override func eventBeers(fromEventId eventId: Int, eventBeerDAO: EventBeerDAO = EventBeerDAO(), userDataHandler: UserDataHandler = UserDataHandler()) -> [EventBeer] {
            return [
                try! EventBeer(id: 1, userId: 1, beerId: 1, eventId: 1, round: 1, votes: voteCountOverride, score: 1, isBeingPoured: isBeingPouredOverride, userDataHandler: FakeUserDataHander()),
                try! EventBeer(id: 2, userId: 2, beerId: 2, eventId: 1, round: roundOverride, votes: 0, score: 0, isBeingPoured: false, userDataHandler: FakeUserDataHander())
            ]
        }
        
        override func save(eventBeer: inout EventBeer, eventBeerDAO: EventBeerDAO = EventBeerDAO()) throws {
            didSave = true
        }
    }
    
    class FakeNoEventBeerDataHandler: EventBeerDataHandler {
        override func eventBeerExists(fromEventId eventId: Int, andUserId userId: Int, eventBeerDAO: EventBeerDAO = EventBeerDAO()) -> Bool {
            return false
        }
        
        override func save(eventBeer: inout EventBeer, eventBeerDAO: EventBeerDAO = EventBeerDAO()) throws {
            // no-op
        }
    }
    
    class SpyEventController: EventController {
        var didEnd = false
        
        override func end(event: Event, eventDataHandler: EventDataHandler = EventDataHandler(), pouredBeers: [EventBeer], eventBeerDataHandler: EventBeerDataHandler = EventBeerDataHandler(), beerDataHandler: BeerDataHandler = BeerDataHandler()) throws {
            didEnd = true
        }
    }
}
