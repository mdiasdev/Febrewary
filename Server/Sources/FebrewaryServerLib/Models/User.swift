//
//  User.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/4/19.
//

import Foundation
import StORM
import PostgresStORM

class User: PostgresStORM {
    var id: Int = 0
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var beers: [Int] = []
    var events: [Int] = []
    
    override open func table() -> String { return "users" }
    
    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        firstName = this.data["firstname"] as? String ?? ""
        lastName = this.data["lastname"] as? String ?? ""
        email = this.data["email"] as? String ?? ""
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
    
    func asDictionary() -> [String: Any] {
        return [
            "id": self.id,
            "firstName": self.firstName,
        ]
    }
}
