//
//  AuthServiceTests.swift
//  FebrewaryTests
//
//  Created by Matthew Dias on 6/29/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import XCTest

@testable import Febrewary

class AuthServiceTests: XCTestCase {

    var sut: AuthService!
    var fakeService: FakeServiceClient!
    let fakeDefaults = FakeUserDefaults()
    
    override func setUp() {
        super.setUp()
        
        fakeService = FakeServiceClient()
        sut = AuthService(client: fakeService, defaults: fakeDefaults)
    }
    
    override func tearDown() {
        fakeService = nil
        sut = nil
        
        super.tearDown()
    }
    
    func test_createAccount_savesAuthToken_whenSuccessful() {
        fakeService.successFileName = "Auth"
        let completed = expectation(description: "call should complete")
        
        sut.createAccount(name: "someone",
                          email: "me@you.org",
                          password: "hello stream!") { result in
            switch result {
            case .success:
                XCTAssertNotNil(self.fakeDefaults.getToken)
                XCTAssertNotNil(User().retrieve())
            case .failure:
                XCTFail("something went wrong here")
            }
            completed.fulfill()
        }
        
        wait(for: [completed], timeout: 1.0)
    }
    
    func test_signIn_savesAuthToken_whenSuccessful() {
        fakeService.successFileName = "Auth"
        let completed = expectation(description: "call should complete")
        
        sut.signIn(email: "me@you.org", password: "hello chat!") { (result) in
            switch result {
            case .success:
                XCTAssertNotNil(self.fakeDefaults.getToken)
                XCTAssertNotNil(User().retrieve())
            case .failure:
                XCTFail("something went wrong here")
            }
            completed.fulfill()
        }
        
        wait(for: [completed], timeout: 1.0)
    }

}
