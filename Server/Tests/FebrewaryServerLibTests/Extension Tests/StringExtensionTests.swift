//
//  StringExtensionTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 6/8/19.
//

import XCTest

@testable import FebrewaryServerLib

class StringExtensionTests: XCTestCase {
    
    static var allTests = [
        ("test_canConvertString_ofObjectIds_toArray", test_canConvertString_ofObjectIds_toArray),
        ("test_canConvertString_ofObjectIds_toArray_whenWhiteSpacePresent", test_canConvertString_ofObjectIds_toArray_whenWhiteSpacePresent),
        ("test_random_providesRandomString", test_random_providesRandomString),
        ("test_generateHash_makesDifferentString", test_generateHash_makesDifferentString),
    ]

    func test_canConvertString_ofObjectIds_toArray() {
        let sut = "1,2,3,4,5"
        let expectedResult = [1, 2, 3, 4, 5]
        
        let actualResult = sut.toIdArray()
        
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    func test_canConvertString_ofObjectIds_toArray_whenWhiteSpacePresent() {
        let sut = "1, 2, 3, 4, 5"
        let expectedResult = [1, 2, 3, 4, 5]
        
        let actualResult = sut.toIdArray()
        
        XCTAssertEqual(expectedResult, actualResult)
    }

    func test_random_providesRandomString() {
        let firstRando = String.random(length: 12)
        let secondRando = String.random(length: 12)
        
        XCTAssertNotEqual(firstRando, secondRando)
    }
    
    func test_generateHash_makesDifferentString() {
        let unexpectedResult = "Hello Stream!"
        
        let actualResult = try! unexpectedResult.generateHash(salt: "s0m3H4sh")
        
        XCTAssertNotEqual(unexpectedResult, actualResult)
    }
}
