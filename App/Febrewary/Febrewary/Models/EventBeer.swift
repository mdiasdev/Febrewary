//
//  EventBeer.swift
//  Febrewary
//
//  Created by Matthew Dias on 7/27/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

struct EventBeer {
    var id: Int
    var attendee: User
    var beer: Beer
    var score: Int
}

extension EventBeer: Codable { }
