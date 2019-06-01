//
//  User.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/27/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

final class User {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let beers: [Beer]
    let events: [Event]
    
    init(id: Int, firstName: String, lastName: String, email: String, beers: [Beer], events: [Event]) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.beers = beers
        self.events = events
    }
    
    convenience init() {
        self.init(id: -1, firstName: "", lastName: "", email: "", beers: [], events: [])
    }
}

extension User: Codable {}

extension User: Cacheable {
    var cacheKey: NSString { return "user" }
    
    func save() {
        Cache.shared.setObject(self, forKey: cacheKey)
    }
    
    func retrieve() -> User? {
        return Cache.shared.object(forKey: cacheKey) as? User
    }
}
