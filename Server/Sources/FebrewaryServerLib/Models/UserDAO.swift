//
//  UserDAO.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/4/19.
//

import Foundation
import StORM
import PostgresStORM

class UserDAO: DAO {
    var id: Int = 0
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var salt: String = ""
    
    override open func table() -> String { return "users" }
    
    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        name = this.data["name"] as? String ?? ""
        email = this.data["email"] as? String ?? ""
        password = this.data["password"] as? String ?? ""
        salt = this.data["salt"] as? String ?? ""
    }
    
    func rows() -> [UserDAO] {
        
        let rows = self.results.rows
        var users = [UserDAO]()
        
        for row in rows {
            let user = UserDAO()
            user.to(row)
            users.append(user)
        }
        
        return users
    }
}

// MARK: - Data Representation
extension UserDAO {
    func asDictionary() -> [String: Any] {
        return [
            "id": self.id,
            "name": self.name,
            "email": self.email,
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
