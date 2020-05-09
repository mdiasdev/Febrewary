//
//  BeerControllerTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 11/26/19.
//

import XCTest

@testable import FebrewaryServerLib

class BeerControllerTests: XCTestCase {

    static let allTests = [
        ("test_addBeer_respondsWithMalformedJSONError_whenMissingPostBody", test_addBeer_respondsWithMalformedJSONError_whenMissingPostBody),
        ("test_addBeer_respondsWithMissingPropertyError_whenMissingBeerName", test_addBeer_respondsWithMissingPropertyError_whenMissingBeerName),
        ("test_addBeer_respondsWithMissingPropertyError_whenMissingBrewerName", test_addBeer_respondsWithMissingPropertyError_whenMissingBrewerName),
        ("test_addBeer_respondsWithMissingPropertyError_whenMissingABV", test_addBeer_respondsWithMissingPropertyError_whenMissingABV),
        ("test_addBeer_respondsWithBeerExistsError_whenBeerBeingAddedIsAlreadyInDataBase", test_addBeer_respondsWithBeerExistsError_whenBeerBeingAddedIsAlreadyInDataBase),
        ("test_addBeer_respondsWithBeer_whenBeerSuccessfullyCreated", test_addBeer_respondsWithBeer_whenBeerSuccessfullyCreated)
    ]

    // MARK: -
    // MARK: - Add Beer
    func test_addBeer_respondsWithMalformedJSONError_whenMissingPostBody() {
        let fakeRequest = FakeRequest()
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let expectedString = " {\n     title: Malformed Request JSON,\n     message: Unable to parse JSON.,\n     code: 400\n }"
        
        BeerController().addBeer(request: fakeRequest, response: spyResponse, userDataHandler: userDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
            XCTAssertEqual(spyResponse.status.code, 400)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_addBeer_respondsWithMissingPropertyError_whenMissingBeerName() {
        let fakeRequest = FakeRequest()
        fakeRequest.postBodyString = "{ \"brewer\": \"Some Brewer\", \"abv\": 4.2}"
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let expectedString = " {\n     title: Missing request property,\n     message: One or more properties are missing.,\n     code: 400\n }"
        
        BeerController().addBeer(request: fakeRequest, response: spyResponse, userDataHandler: userDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
            XCTAssertEqual(spyResponse.status.code, 400)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_addBeer_respondsWithMissingPropertyError_whenMissingBrewerName() {
        let fakeRequest = FakeRequest()
        fakeRequest.postBodyString = "{ \"name\": \"Some Beer\", \"abv\": 4.2}"
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let expectedString = " {\n     title: Missing request property,\n     message: One or more properties are missing.,\n     code: 400\n }"
        
        BeerController().addBeer(request: fakeRequest, response: spyResponse, userDataHandler: userDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
            XCTAssertEqual(spyResponse.status.code, 400)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_addBeer_respondsWithMissingPropertyError_whenMissingABV() {
        let fakeRequest = FakeRequest()
        fakeRequest.postBodyString = "{ \"name\": \"Some Beer\", \"brewer\": \"Some Brewer\"}"
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let expectedString = " {\n     title: Missing request property,\n     message: One or more properties are missing.,\n     code: 400\n }"
        
        BeerController().addBeer(request: fakeRequest, response: spyResponse, userDataHandler: userDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
            XCTAssertEqual(spyResponse.status.code, 400)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_addBeer_respondsWithBeerExistsError_whenBeerBeingAddedIsAlreadyInDataBase() {
        let fakeRequest = FakeRequest()
        fakeRequest.postBodyString = "{ \"name\": \"Some Beer\", \"brewer\": \"Some Brewer\", \"abv\": 4.2}"
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let beerDataHandler = FakeBeerDataHandler()
        beerDataHandler.existsOverride = true
        let expectedString = " {\n     title: Cannot Add Beer,\n     message: The Beer you\'re trying to add already exists.,\n     code: 409\n }"
        
        BeerController().addBeer(request: fakeRequest, response: spyResponse, userDataHandler: userDataHandler, beerDataHandler: beerDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
            XCTAssertEqual(spyResponse.status.code, 409)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    func test_addBeer_respondsWithBeer_whenBeerSuccessfullyCreated() {
        let fakeRequest = FakeRequest()
        fakeRequest.postBodyString = "{ \"name\": \"Some Beer\", \"brewer\": \"Some Brewer\", \"abv\": 4.2}"
        let spyResponse = SpyResponse()
        let userDataHandler = MockSuccessfulUserDataHandler()
        let beerDataHandler = FakeBeerDataHandler()
        let expectedString = "{\n  \"brewer\" : \"Some Brewer\",\n  \"id\" : 0,\n  \"totalScore\" : 0,\n  \"abv\" : 4.1999998092651367,\n  \"totalVotes\" : 0,\n  \"name\" : \"Some Beer\",\n  \"addedBy\" : 1\n}"
        
        BeerController().addBeer(request: fakeRequest, response: spyResponse, userDataHandler: userDataHandler, beerDataHandler: beerDataHandler)
        
        if let string = String(bytes: spyResponse.bodyBytes, encoding: .utf8) {
            XCTAssertEqual(string, expectedString)
            XCTAssertEqual(spyResponse.status.code, 201)
            XCTAssertTrue(beerDataHandler.didSave)
        } else {
            XCTFail("not a valid UTF-8 sequence")
        }
    }
    
    // MARK: - Beer For Current User
}

// MARK: -
// MARK: - Test Doubles
class FakeBeerDataHandler: BeerDataHandler {
    var existsOverride = false
    var didSave = false
    
    override func beerExists(withName name: String, by brewer: String, beerDAO: BeerDAO = BeerDAO()) -> Bool {
        return existsOverride
    }
    
    override func save(beer: inout Beer, beerDAO: BeerDAO = BeerDAO()) throws {
        didSave = true
    }
}
