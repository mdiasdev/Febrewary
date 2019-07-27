//
//  URLBuilderTests.swift
//  FebrewaryTests
//
//  Created by Matthew Dias on 7/27/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import XCTest

@testable import Febrewary

class URLBuilderTests: XCTestCase {

    func test_buildUrl_withoutComponents_buildsBasicURL() {
        let expectedURL = URL(string: "http://localhost:8080/beer")
        
        let actualURL = URLBuilder(endpoint: .beer).buildUrl()
        
        XCTAssertEqual(expectedURL, actualURL)
    }

    func test_buildUrl_withComponents_buildsComplexURL() {
        let expectedURL = URL(string: "http://localhost:8080/beer?query=hello%20Stream")
        
        let actualURL = URLBuilder(endpoint: .beer).buildUrl(components: [("query", "hello Stream")])
        
        XCTAssertEqual(expectedURL, actualURL)
    }
}
