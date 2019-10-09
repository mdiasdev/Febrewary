//
//  UserDataHandler.swift
//  COpenSSL
//
//  Created by Matthew Dias on 10/2/19.
//

import Foundation
import PerfectHTTP

struct User: Codable {
    var id: Int = 0
    var name: String = ""
    var email: String = ""
    
    init(id: Int, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    fileprivate init(userDAO: UserDAO) {
        self.id = userDAO.id
        self.name = userDAO.name
        self.email = userDAO.email
    }
    
    fileprivate init(id: Int, userDAO: UserDAO = UserDAO()) throws {
        try userDAO.find(by: ["id": id])
        
        guard let dao = userDAO.rows().first, dao.id > 0 else { throw UserNotFoundError() }
        
        self = User(userDAO: dao)
    }
    
    fileprivate init(request: HTTPRequest, userDAO: UserDAO = UserDAO()) throws {
        guard let email = request.emailFromAuthToken() else { throw BadTokenError() }
        
        do {
            try userDAO.find(by: ["email": email])
            
            guard let dao = userDAO.rows().first, dao.id > 0 else { throw BadTokenError() }
            
            self = User(userDAO: dao)
        } catch {
            throw BadTokenError()
        }
    }
}

class UserDataHandler {
    
    func user(from id: Int, userDAO: UserDAO = UserDAO()) throws -> User {
        return try User(id: id, userDAO: userDAO)
    }
    
    /// Get a user, from the database, for a given Perfect Request
    /// - Parameter request: the request to pull auth token from in order to find a user
    /// - Parameter userDAO: database access object for dependency inject
    ///
    /// - Attention: this can **throw** `BadTokenError`, `StORMError`
    func user(from request: HTTPRequest, userDAO: UserDAO = UserDAO()) throws -> User {
        return try User(request: request, userDAO: userDAO)
    }
    
    func user(from userDAO: UserDAO) -> User {
        return User(userDAO: userDAO)
    }
    
    func getAllUsers(userDAO: UserDAO = UserDAO()) throws -> [User] {
        try userDAO.getAll()
        
        return userDAO.rows().map { User(userDAO: $0) }
    }
    
    func json(from user: User) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(user)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw UnauthenticatedError()
        }
        
        return jsonString
    }
}
