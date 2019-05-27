//
//  File.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/27/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

struct User {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let beers: [Beer]
    let events: [Event]
}
