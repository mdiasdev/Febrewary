//
//  Event.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/27/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

struct Event {
    let id: Int
    let name: String
    let address: String
    let date: Date
    let pourerId: Int
    let hasStarted: Bool
    let isOver: Bool
    let attendees: [User]
    let eventBeers: [EventBeer]
}

extension Event: Codable { }
