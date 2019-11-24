//
//  BeerDataHandler.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 11/12/19.
//

import Foundation

struct Beer: Codable {
    var id: Int = 0

    var name: String
    var brewer: String
    var abv: Float
    var addedBy: Int

    var totalScore: Int = 0
    var totalVotes: Int = 0
    
    init(id: Int, name: String, brewer: String, abv: Float, addedBy: Int) {
        self.id = id
        self.name = name
        self.brewer = brewer
        self.abv = abv
        self.addedBy = addedBy
    }
    
    init(beerDAO: BeerDAO) {
        self.id = beerDAO.id
        self.name = beerDAO.name
        self.brewer = beerDAO.brewer
        self.abv = beerDAO.abv
        self.addedBy = beerDAO.addedBy
        self.totalScore = beerDAO.totalScore
        self.totalVotes = beerDAO.totalVotes
    }
}

class BeerDataHandler {
    func beer(with id: Int, beerDAO: BeerDAO = BeerDAO()) throws -> Beer {
        try beerDAO.find(by: [("id", id)])
        
        guard beerDAO.rows().count == 1, let beer = beerDAO.rows().first, beer.id > 0 else { throw DatabaseError() }
        
        return Beer(beerDAO: beer)
    }
    
    func save(beer: inout Beer, beerDAO: BeerDAO = BeerDAO()) throws {
        try beerDAO.save(set: { id in
            beerDAO.id = id as! Int
            beer.id = id as! Int
        })
    }
}
