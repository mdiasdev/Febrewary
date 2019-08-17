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
    let name: String

    let email: String
    
    init(id: Int, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    convenience init() {
        self.init(id: -1, name: "", email: "")
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
