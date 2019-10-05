//
//  UserControllerTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 10/5/19.
//

import XCTest
import PerfectHTTP

@testable import FebrewaryServerLib

class UserControllerTests: XCTestCase {

    static var allTests = [
        ("test_getCurrentUser_respondsWithUserJson_whenSuccessful", test_getCurrentUser_respondsWithUserJson_whenSuccessful),
    ]
    
    func test_getCurrentUser_respondsWithUserJson_whenSuccessful() {
        let fakeRequest = FakeRequest()
        let fakeToken = try! validAuthToken()
        fakeRequest.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, fakeToken)].makeIterator())
        let spyResponse = SpyResponse()
        let mockUserDataHandler = MockSuccessfulUserDataHandler()
        let expectString = "{\n  \"id\" : 1,\n  \"name\" : \"Hello Stream\",\n  \"email\" : \"hello@stream.com\"\n}"
        
        UserController().getCurrentUser(request: fakeRequest, response: spyResponse, userDataHandler: mockUserDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }

}

class MockSuccessfulUserDataHandler: UserDataHandler {
    override func user(from request: HTTPRequest, userDAO: UserDAO = UserDAO()) throws -> User {
        return User(id: 1, name: "Hello Stream", email: "hello@stream.com")
    }
}

class SpyResponse: HTTPResponse {
    var request: HTTPRequest = FakeRequest()
    var status: HTTPResponseStatus = .ok
    var isStreaming: Bool = false
    var bodyBytes: [UInt8] = []
    var headers: AnyIterator<(HTTPResponseHeader.Name, String)> = AnyIterator([].makeIterator())
    
    func header(_ named: HTTPResponseHeader.Name) -> String? {
        return nil
    }
    
    func addHeader(_ named: HTTPResponseHeader.Name, value: String) -> Self {
        return self
    }
    
    func setHeader(_ named: HTTPResponseHeader.Name, value: String) -> Self {
        return self
    }
    
    func push(callback: @escaping (Bool) -> ()) {
        callback(true)
    }
    
    // no-op
    func next() { }
    func completed() { }
}
