//
//  Beer.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/27/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

struct Beer {
    var id: Int
    var name: String
    var brewerName: String
    var abv: Double
    var addedBy: Int
    var averageScore: Double
    var totalScore: Double
}

extension Beer: Codable { }
