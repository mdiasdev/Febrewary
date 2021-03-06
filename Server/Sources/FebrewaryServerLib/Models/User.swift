//
//  User.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/4/19.
//

import Foundation
import StORM
import PostgresStORM

class User: DAO {
    var id: Int = 0
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var salt: String = ""
    var beers: [Int] = []
    var events: [Int] = []
    
    override open func table() -> String { return "users" }
    
    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        name = this.data["name"] as? String ?? ""
        email = this.data["email"] as? String ?? ""
        password = this.data["password"] as? String ?? ""
        salt = this.data["salt"] as? String ?? ""
        beers = this.data["beers"] as? [Int] ?? []
        events = this.data["events"] as? [Int] ?? []
    }
    
    func rows() -> [User] {
        
        let rows = self.results.rows
        var users = [User]()
        
        for row in rows {
            let user = User()
            user.to(row)
            users.append(user)
        }
        
        return users
    }
}

// MARK: - Data Representation
extension User {
    func asDictionary() -> [String: Any] {
        return [
            "id": self.id,
            "name": self.name,
            "email": self.email,
            "events": self.events,
            "beers": self.beers,
        ]
    }
    
    func asSimpleDictionary() -> [String: Any] {
        return [
            "id": self.id,
            "name": self.name,
            "email": self.email,
        ]
    }
}
