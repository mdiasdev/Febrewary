//
//  UserTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 7/30/19.
//

import XCTest

@testable import FebrewaryServerLib

class UserTests: XCTestCase {
    
    static var allTests = [
        ("test_rows_returnsArrayOfUsers", test_rows_returnsArrayOfUsers),
    ]
    
    var sut: MockUserDAO!

    override func setUp() {
        super.setUp()
        
        sut = MockUserDAO()
        try! sut.getAll()
    }

    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }

    func test_rows_returnsArrayOfUsers() {
        let users = sut.rows()
        
        XCTAssertEqual(users.count, 2)
    }
    
    func test_to_parsesIntoCorrectObject() {
        sut.to(sut.results.rows.first!)
        
        XCTAssertEqual(sut.id, 1)
    }
}
