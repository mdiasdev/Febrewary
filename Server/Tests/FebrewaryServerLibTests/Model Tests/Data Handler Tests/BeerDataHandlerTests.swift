//
//  BeerDataHandlerTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 11/24/19.
//

import XCTest

@testable import FebrewaryServerLib

class BeerDataHandlerTests: XCTestCase {

    static var allTests = [
        ("test_beerWithId_throwDatabaseError_whenBeerNotFound", test_beerWithId_throwDatabaseError_whenBeerNotFound),
        ("test_beerWithId_doesNotThrow_whenBeerIsFound", test_beerWithId_doesNotThrow_whenBeerIsFound),
        ("test_save_setsIdOnBeer", test_save_setsIdOnBeer)
    ]
    
    func test_beerWithId_throwDatabaseError_whenBeerNotFound() {
        XCTAssertThrowsError(
            try BeerDataHandler().beer(with: 1, beerDAO: MockNoBeerDAO())
        ) { error in
            XCTAssertTrue(error is DatabaseError)
        }
    }
    
    func test_beerWithId_doesNotThrow_whenBeerIsFound() {
        XCTAssertNoThrow(try BeerDataHandler().beer(with: 1, beerDAO: MockSingleBeerDAO()))
    }

    func test_save_setsIdOnBeer() {
        var beer = Beer(id: 1, name: "Tasty", brewer: "Goodeness", abv: 42.0, addedBy: 1)
        let beerDAO = MockNoBeerDAO()
        beerDAO.id = 0
        
        XCTAssertNoThrow(try BeerDataHandler().save(beer: &beer, beerDAO: beerDAO))
        XCTAssertEqual(1, beer.id)
        XCTAssertEqual(1, beer.id)
    }
}
