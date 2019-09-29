//
//  RouterTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 9/28/19.
//

import XCTest
import PerfectHTTP
import PerfectCrypto

@testable import FebrewaryServerLib

class RouterTests: XCTestCase {

    static var allTests = [
        ("test_initializingRouter_intializesRoutes", test_initializingRouter_intializesRoutes),
        ("test_validateAuth_throws_ifEmailMissing", test_validateAuth_throws_ifEmailMissing),
        ("test_validateAuth_throws_ifEmailWrongType", test_validateAuth_throws_ifEmailWrongType),
    ]
    
    var sut: SpyRouter!
    
    override func setUp() {
        super.setUp()
        
        sut = SpyRouter()
    }

    func test_initializingRouter_intializesRoutes() {
        XCTAssertTrue(sut.didInitializeRoutes)
    }
    
    func test_validateAuth_throws_ifEmailMissing() {
        let fakeRequest = FakeRequest()
        let fakeToken = try! invalidAuthToken_missingEmail()
        fakeRequest.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, fakeToken)].makeIterator())
        
        XCTAssertThrowsError(try sut.validateAuth(request: fakeRequest)) { error in
            XCTAssertEqual(error as! UnauthenticatedError, UnauthenticatedError())
        }
    }
    
    func test_validateAuth_throws_ifEmailWrongType() {
        let fakeRequest = FakeRequest()
        let fakeToken = try! invalidAuthToken_emailWrongType()
        fakeRequest.headers = AnyIterator([(HTTPRequestHeader.Name.authorization, fakeToken)].makeIterator())
        
        XCTAssertThrowsError(try sut.validateAuth(request: fakeRequest)) { error in
            XCTAssertEqual(error as! BadTokenError, BadTokenError())
        }
    }
    
    // MARK: - Test Helpers
    
    class SpyRouter: Router {
        var didInitializeRoutes = false
        
        override func initRoutes() {
            didInitializeRoutes = true
        }
    }
}
