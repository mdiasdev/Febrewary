//
//  UserServiceTests.swift
//  FebrewaryTests
//
//  Created by Matthew Dias on 7/6/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import XCTest

@testable import Febrewary

class UserServiceTests: XCTestCase {

    var sut: UserService!
    var fakeClient: FakeServiceClient!
    
    override func setUp() {
        super.setUp()
        
        fakeClient = FakeServiceClient()
        sut = UserService(client: fakeClient)
    }

    override func tearDown() {
        sut = nil
        fakeClient = nil
        
        super.tearDown()
    }

    func test_getCurrentUser_cachesUser_whenSuccessul() {
        fakeClient.successFileName = "CurrentUser"
        let completed = expectation(description: "call should complete")
        
        sut.getCurrentUser { _ in
            completed.fulfill()
            
            XCTAssertNotNil(User().retrieve())
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

}
