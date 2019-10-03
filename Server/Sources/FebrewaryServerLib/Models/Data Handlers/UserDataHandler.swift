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
