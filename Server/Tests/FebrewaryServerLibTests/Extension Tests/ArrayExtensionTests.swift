//
//  ArrayExtensionTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 6/8/19.
//

import XCTest
@testable import FebrewaryServerLib

class ArrayExtensionTests: XCTestCase {
    static var allTests = [
        ("test_createsCommaSeparatedString", test_createsCommaSeparatedString),
    ]

    func test_createsCommaSeparatedString() {
        let sut = [1, 2, 3, 4, 5]
        let expectedResult = "1, 2, 3, 4, 5"
        
        let actualResult = sut.toString()
        
        XCTAssertEqual(expectedResult, actualResult)
    }

}
