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
    
    init(userDAO: UserDAO) {
        self.id = userDAO.id
        self.name = userDAO.name
        self.email = userDAO.email
    }
    
    init(id: Int, userDAO: UserDAO = UserDAO()) throws {
        try userDAO.find(by: ["id": id])
        
        guard userDAO.id > 0 else {
            throw UserNotFoundError()
        }
    }
    
    init(request: HTTPRequest, userDAO: UserDAO = UserDAO()) throws {
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

struct UserDataHandler {
    
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
