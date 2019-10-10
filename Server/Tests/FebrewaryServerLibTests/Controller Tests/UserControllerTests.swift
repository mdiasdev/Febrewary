//
//  UserControllerTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 10/5/19.
//

import XCTest
import PerfectHTTP
import StORM

@testable import FebrewaryServerLib

class UserControllerTests: XCTestCase {

    static var allTests = [
        ("test_getCurrentUser_respondsWithUserJson_whenSuccessful", test_getCurrentUser_respondsWithUserJson_whenSuccessful),
        ("test_getCurrentUser_respondsWithDatabaseError_whenInvalidToken", test_getCurrentUser_respondsWithDatabaseError_whenInvalidToken),
        ("test_getCurrentUser_respondsWithBadTokenError_whenInvalidToken", test_getCurrentUser_respondsWithBadTokenError_whenInvalidToken),
        ("test_getUserById_throwsMalformedRequestError_whenNoIdInRequest", test_getUserById_throwsMalformedRequestError_whenNoIdInRequest),
        ("test_getUserById_respondsWithUser_whenUserExistsInDatabase", test_getUserById_respondsWithUser_whenUserExistsInDatabase),
        ("test_getUserById_respondsWithUserNotFound_whenUserDoesNotExistInDatabase", test_getUserById_respondsWithUserNotFound_whenUserDoesNotExistInDatabase),
        ("test_getUserById_respondsWithDatabaseError_whenDatabaseHasProblem", test_getUserById_respondsWithDatabaseError_whenDatabaseHasProblem),
        ("test_getAllUsers_respondsEmpty_whenDatabaseIsEmpty", test_getAllUsers_respondsEmpty_whenDatabaseIsEmpty),
        ("test_getAllUsers_respondsWithUsers_whenDatabaseIsNotEmpty", test_getAllUsers_respondsWithUsers_whenDatabaseIsNotEmpty),
        ("test_getAllUsers_respondsWithDatabaseError_whenDatabaseHasProblem", test_getAllUsers_respondsWithDatabaseError_whenDatabaseHasProblem),
    ]
    
    // MARK: - getCurrentUser() Tests
    func test_getCurrentUser_respondsWithUserJson_whenSuccessful() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
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
    
    func test_getCurrentUser_respondsWithDatabaseError_whenInvalidToken() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        let spyResponse = SpyResponse()
        let mockUserDataHandler = MockDatabaseErrorUserDataHandler()
        let expectString = " {\n     title: Internal Error,\n     message: Something went wrong.,\n     code: 500\n }"
        
        UserController().getCurrentUser(request: fakeRequest, response: spyResponse, userDataHandler: mockUserDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_getCurrentUser_respondsWithBadTokenError_whenInvalidToken() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! invalidAuthToken_missingEmail())
        let spyResponse = SpyResponse()
        let mockUserDataHandler = MockBadTokenUserDataHandler()
        let expectString = " {\n     title: Bad Auth Token,\n     message: The auth token used is malformed.,\n     code: 400\n }"
        
        UserController().getCurrentUser(request: fakeRequest, response: spyResponse, userDataHandler: mockUserDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    // MARK: - getUserById() Tests

    func test_getUserById_throwsMalformedRequestError_whenNoIdInRequest() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.pathComponents = ["user"]
        let spyResponse = SpyResponse()
        let expectString = " {\n     title: Malformed Request,\n     message: Missing a required query parameter.,\n     code: 400\n }"
        
        UserController().getUserById(request: fakeRequest, response: spyResponse)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_getUserById_respondsWithUser_whenUserExistsInDatabase() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.pathComponents = ["user", "1"]
        let spyResponse = SpyResponse()
        let mockUserDataHandler = MockSuccessfulUserDataHandler()
        let expectString = "{\n  \"id\" : 1,\n  \"name\" : \"Hello Stream\",\n  \"email\" : \"hello@stream.com\"\n}"
        
        UserController().getUserById(request: fakeRequest, response: spyResponse, userDataHandler: mockUserDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_getUserById_respondsWithUserNotFound_whenUserDoesNotExistInDatabase() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.pathComponents = ["user", "1"]
        let spyResponse = SpyResponse()
        let mockUserDataHandler = MockUserNotFoundUserDataHandler()
        let expectString = " {\n     title: Failed to find User,\n     message: This user does not exist.,\n     code: 404\n }"
        
        UserController().getUserById(request: fakeRequest, response: spyResponse, userDataHandler: mockUserDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_getUserById_respondsWithDatabaseError_whenDatabaseHasProblem() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.pathComponents = ["user", "1"]
        let spyResponse = SpyResponse()
        let mockUserDataHandler = MockDatabaseErrorUserDataHandler()
        let expectString = " {\n     title: Internal Error,\n     message: Something went wrong.,\n     code: 500\n }"
        
        UserController().getUserById(request: fakeRequest, response: spyResponse, userDataHandler: mockUserDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    // MARK: - getAllUsers Tests
    func test_getAllUsers_respondsEmpty_whenDatabaseIsEmpty() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        let spyResponse = SpyResponse()
        let mockUserDataHandler = MockSuccessfulEmptyDatabaseUserDataHandler()
        let expectString = "[]"
        
        UserController().getAllUsers(request: fakeRequest, response: spyResponse, userDataHandler: mockUserDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_getAllUsers_respondsWithUsers_whenDatabaseIsNotEmpty() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        let spyResponse = SpyResponse()
        let mockUserDataHandler = MockSuccessfulUserDataHandler()
        let expectString = "[{\n  \"id\" : 1,\n  \"name\" : \"Hello Stream\",\n  \"email\" : \"hello@stream.com\"\n}, {\n  \"id\" : 1,\n  \"name\" : \"Hello Stream\",\n  \"email\" : \"hello@stream.com\"\n}]"
        
        UserController().getAllUsers(request: fakeRequest, response: spyResponse, userDataHandler: mockUserDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_getAllUsers_respondsWithDatabaseError_whenDatabaseHasProblem() {
        let fakeRequest = FakeRequestBuilder.request(withToken: try! validAuthToken())
        fakeRequest.pathComponents = ["user", "1"]
        let spyResponse = SpyResponse()
        let mockUserDataHandler = MockDatabaseErrorUserDataHandler()
        let expectString = " {\n     title: Internal Error,\n     message: Something went wrong.,\n     code: 500\n }"
        
        UserController().getAllUsers(request: fakeRequest, response: spyResponse, userDataHandler: mockUserDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectString)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
}

// MARK: - Test Doubles
class MockSuccessfulUserDataHandler: UserDataHandler {
    override func user(from request: HTTPRequest, userDAO: UserDAO = UserDAO()) throws -> User {
        return User(id: 1, name: "Hello Stream", email: "hello@stream.com")
    }
    
    override func user(from id: Int, userDAO: UserDAO = UserDAO()) throws -> User {
        return User(id: 1, name: "Hello Stream", email: "hello@stream.com")
    }
    
    override func getAllUsers(userDAO: UserDAO = UserDAO()) throws -> [User] {
        return [User(id: 1, name: "Hello Stream", email: "hello@stream.com"), User(id: 1, name: "Hello Stream", email: "hello@stream.com")]
    }
}

class MockSuccessfulEmptyDatabaseUserDataHandler: UserDataHandler {
    override func getAllUsers(userDAO: UserDAO = UserDAO()) throws -> [User] {
        return []
    }
}

class MockBadTokenUserDataHandler: UserDataHandler {
    override func user(from request: HTTPRequest, userDAO: UserDAO = UserDAO()) throws -> User {
        throw BadTokenError()
    }
}

class MockDatabaseErrorUserDataHandler: UserDataHandler {
    override func user(from request: HTTPRequest, userDAO: UserDAO = UserDAO()) throws -> User {
        throw StORMError.database
    }
    
    override func user(from id: Int, userDAO: UserDAO = UserDAO()) throws -> User {
        throw StORMError.database
    }
}

class MockUserNotFoundUserDataHandler: UserDataHandler {
    override func user(from id: Int, userDAO: UserDAO = UserDAO()) throws -> User {
        throw UserNotFoundError()
    }
}

struct FakeRequestBuilder {
    static func request(withToken token: String) -> FakeRequest {
        let fakeRequest = FakeRequest()
        fakeRequest.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, token)].makeIterator())
        
        return fakeRequest
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
