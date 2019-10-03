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

    // MARK: Initializer Tests
    func test_initializing_withUserDAO_createsUser() {
        let fakeUserDAO = UserDAO()
        fakeUserDAO.id = 1
        fakeUserDAO.name = "Test User"
        fakeUserDAO.email = "something@fake.net"
        
        let user = User(userDAO: fakeUserDAO)
        
        verifyEqualityBetween(user: user, and: fakeUserDAO)
    }
    
    func test_initializing_withValidRequest_createsUser() {
        let fakeRequest = FakeRequest()
        let fakeToken = try! validAuthToken()
        fakeRequest.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, fakeToken)].makeIterator())

        XCTAssertNoThrow(try User(request: fakeRequest, userDAO: MockUser()))
        
        // FIXME: WHY?!?!
//        try! dao.find(by: ["it": "doesn't matter"])
//        verifyEqualityBetween(user: user!, and: dao)
    }
    
    func test_initializing_withInvalidRequest_throwsBadToken() {
        let fakeRequest = FakeRequest()
        let fakeToken = try! invalidAuthToken_missingEmail()
        fakeRequest.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, fakeToken)].makeIterator())

        XCTAssertThrowsError(try User(request: fakeRequest, userDAO: MockUser())) { error in
            XCTAssertTrue(error is BadTokenError)
        }
    }
    
    func test_initializing_withInvalidUser_throwsBadToken() {
        let fakeRequest = FakeRequest()
        let fakeToken = try! invalidAuthToken_missingEmail()
        fakeRequest.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, fakeToken)].makeIterator())

        XCTAssertThrowsError(try User(request: fakeRequest, userDAO: BadUser())) { error in
            XCTAssertTrue(error is BadTokenError)
        }
    }
    
    // MARK: Test Helpers
    func verifyEqualityBetween(user: User, and userDAO: UserDAO, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(user.id, userDAO.id, file: file, line: line)
        XCTAssertEqual(user.name, userDAO.name, file: file, line: line)
        XCTAssertEqual(user.email, userDAO.email, file: file, line: line)
    }

}
