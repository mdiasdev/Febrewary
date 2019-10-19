//
//  UserDataHandlerTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 10/2/19.
//

import XCTest
import PerfectHTTP

@testable import FebrewaryServerLib

class UserDataHandlerTests: XCTestCase {
    
    static var allTests = [
        ("test_initializing_withUserDAO_createsUser", test_initializing_withUserDAO_createsUser),
        ("test_initializing_withValidRequest_createsUser", test_initializing_withValidRequest_createsUser),
        ("test_initializing_withValidRequest_createsUser", test_initializing_withValidRequest_createsUser),
        ("test_initializing_withInvalidUser_throwsBadToken", test_initializing_withInvalidUser_throwsBadToken),
        ("test_jsonFromUser_returnsUserAsJSONString", test_jsonFromUser_returnsUserAsJSONString),
    ]
    
    var sut: UserDataHandler!
    
    override func setUp() {
        super.setUp()
        
        sut = UserDataHandler()
    }

    // MARK: Initializer Tests
    func test_initializing_withUserDAO_createsUser() {
        let fakeUserDAO = UserDAO()
        fakeUserDAO.id = 1
        fakeUserDAO.name = "Test User"
        fakeUserDAO.email = "something@fake.net"
        
        let user = sut.user(from: fakeUserDAO)
        
        verifyEqualityBetween(user: user, and: fakeUserDAO)
    }
    
    func test_initializing_withId_createsUser() {
        let mockDAO = MockUserDAO()
        
        let user = try! sut.user(from: 1, userDAO: mockDAO)
        
        verifyEqualityBetween(user: user, and: mockDAO)
    }
    
    func test_initializing_withValidRequest_createsUser() {
        let fakeRequest = FakeRequest()
        let fakeToken = try! validAuthToken()
        fakeRequest.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, fakeToken)].makeIterator())

        XCTAssertNoThrow(try sut.user(from: fakeRequest, userDAO: MockUserDAO()))
        
        // FIXME: WHY?!?!
//        try! dao.find(by: ["it": "doesn't matter"])
//        verifyEqualityBetween(user: user!, and: dao)
    }
    
    func test_initializing_withInvalidRequest_throwsBadToken() {
        let fakeRequest = FakeRequest()
        let fakeToken = try! invalidAuthToken_missingEmail()
        fakeRequest.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, fakeToken)].makeIterator())

        XCTAssertThrowsError(try sut.user(from: fakeRequest, userDAO: MockUserDAO())) { error in
            XCTAssertTrue(error is BadTokenError)
        }
    }
    
    func test_initializing_withInvalidUser_throwsBadToken() {
        let fakeRequest = FakeRequest()
        let fakeToken = try! invalidAuthToken_missingEmail()
        fakeRequest.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, fakeToken)].makeIterator())

        XCTAssertThrowsError(try sut.user(from: fakeRequest, userDAO: BadUser())) { error in
            XCTAssertTrue(error is BadTokenError)
        }
    }
    
    // MARK: - JSON Builder
    func test_jsonFromUser_returnsUserAsJSONString() {
        let testUser = User(id: 1, name: "yo dude", email: "hello@stream.com")
        let expected = """
        {
          "id" : 1,
          "name" : "yo dude",
          "email" : "hello@stream.com"
        }
        """
        
        let actual = try! UserDataHandler().json(from: testUser)
        
        XCTAssertEqual(expected, actual)
    }
    
    // MARK: - Test Helpers
    func verifyEqualityBetween(user: User, and userDAO: UserDAO, file: StaticString = #file, line: UInt = #line) {
        if let userDAO = userDAO.rows().first {
            XCTAssertEqual(user.id, userDAO.id, file: file, line: line)
            XCTAssertEqual(user.name, userDAO.name, file: file, line: line)
            XCTAssertEqual(user.email, userDAO.email, file: file, line: line)
            return
        }
        XCTAssertEqual(user.id, userDAO.id, file: file, line: line)
        XCTAssertEqual(user.name, userDAO.name, file: file, line: line)
        XCTAssertEqual(user.email, userDAO.email, file: file, line: line)
    }

}
