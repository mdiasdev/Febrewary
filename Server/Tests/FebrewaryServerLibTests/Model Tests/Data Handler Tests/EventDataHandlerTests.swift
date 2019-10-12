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
        ("test_jsonFromEvent_returnsUserAsJSONString", test_jsonFromEvent_returnsUserAsJSONString),
        ("test_save_setsEventID_afterSaving", test_save_setsEventID_afterSaving),
        
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
    
    // MARK: - Save
    func test_save_setsEventID_afterSaving() {
        var event = Event(name: "Fun Times", date: "tomorrow", address: "my home", createdBy: 1)
        let fakeEventDAO = FakeEventDAO()
        
        try! EventDataHandler().save(event: &event, eventDAO: fakeEventDAO)
        
        XCTAssertEqual(event.id, fakeEventDAO.id)
        XCTAssertGreaterThan(event.id, 0)
    }
    
    // MARK: - JSON Builder
    func test_jsonFromEvent_returnsUserAsJSONString() {
        let event = Event(name: "Fun Times", date: "tomorrow", address: "my home", createdBy: 1)
        let expected = "{\n  \"isOver\" : false,\n  \"pourerId\" : 0,\n  \"address\" : \"my home\",\n  \"id\" : 0,\n  \"date\" : \"tomorrow\",\n  \"hasStarted\" : false,\n  \"createdBy\" : 1,\n  \"name\" : \"Fun Times\"\n}"
        
        let actual = try! EventDataHandler().json(from: event)
        
        XCTAssertEqual(expected, actual)
    }
}

class FakeEventDAO: EventDAO {
    override func store(set: (Any) -> Void) throws {
        set(1)
    }
}
