//
//  EventControllerTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 10/8/19.
//

import XCTest

@testable import FebrewaryServerLib

class EventControllerTests: XCTestCase {

    static var allTests = [
        ("test_createEvent_respondsWithMalformedJSONError_whenNoPostBody", test_createEvent_respondsWithMalformedJSONError_whenNoPostBody)
    ]

    func test_createEvent_respondsWithMalformedJSONError_whenNoPostBody(){
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        let spyResponse = SpyResponse()
        let expectedString = " {\n     title: Malformed Request JSON,\n     message: Unable to parse JSON.,\n     code: 400\n }"
        
        EventController().createEvent(request: fakeRequest, response: spyResponse)
        
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
        let expectedString = " {\n     title: Missing request property,\n     message: One or more properties are missing.,\n     code: 400\n }"
        
        EventController().createEvent(request: fakeRequest, response: spyResponse)
        
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
}
