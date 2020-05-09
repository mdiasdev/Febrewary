//
//  BeerDataHandler.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 11/12/19.
//

import Foundation

struct Beer: Codable, Hashable {
    var id: Int = 0

    var name: String
    var brewer: String
    var abv: Float
    var addedBy: Int

    var totalScore: Int = 0
    var totalVotes: Int = 0
    
    init(id: Int = 0, name: String, brewer: String, abv: Float, addedBy: Int) {
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
    func beerExists(withName name: String, by brewer: String, beerDAO: BeerDAO = BeerDAO()) -> Bool {
        try? beerDAO.find(by: [
            "name": name,
            "brewer": brewer ]
        )
        
        return beerDAO.id != 0
    }
    
    func beer(with id: Int, beerDAO: BeerDAO = BeerDAO()) throws -> Beer {
        try beerDAO.find(by: [("id", id)])
        
        guard beerDAO.rows().count == 1, let beer = beerDAO.rows().first, beer.id > 0 else { throw DatabaseError() }
        
        return Beer(beerDAO: beer)
    }
    
    func beers(addedBy userId: Int, beerDAO: BeerDAO = BeerDAO()) -> [Beer] {
        try? beerDAO.find(by: [("addedBy", userId)])
        
        return beerDAO.rows().compactMap { Beer(beerDAO: $0) }
    }
    
    func beers(from eventBeers: [EventBeer], beerDAO: BeerDAO = BeerDAO()) -> [Beer] {
        let query = "id IN (\(eventBeers.compactMap { "\($0.beerId)" }.toString()))"
        try? beerDAO.search(whereClause: query, params: [], orderby: ["id"])
        
        return beerDAO.rows().compactMap { Beer(beerDAO: $0) }
    }
    
    func save(beer: inout Beer, beerDAO: BeerDAO = BeerDAO()) throws {
        try beerDAO.save(set: { id in
            beerDAO.id = id as! Int
            beer.id = id as! Int
        })
    }
    
    func json(from beer: Beer) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(beer)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw DatabaseError()
        }
        
        return jsonString
    }
    
    func jsonArray(from beers: [Beer]) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(beers)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw DatabaseError()
        }
        
        return jsonString
    }
}
