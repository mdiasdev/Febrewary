//
//  UserController.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 6/1/19.
//

import Foundation
import PerfectHTTP
import PerfectCrypto
import StORM

public class UserController: Router {
    override func initRoutes() {
        routes.add(Route(method: .get, uri: "user", handler: getCurrentUser))
        routes.add(Route(method: .get, uri: "user/{id}", handler: getUserById))
        routes.add(Route(method: .get, uri: "users", handler: getAllUsers))
    }
    
    // MARK: - Endpoints
    func getCurrentUser(request: HTTPRequest, response: HTTPResponse) {
        guard request.hasValidToken() else {
            response.setBody(string: "Unauthenicated user. Please login and try again.")
                    .completed(status: .unauthorized)
            return
        }
        
        guard let email = request.emailFromAuthToken() else {
            response.setBody(string: "Bad Header.")
                    .completed(status: .badRequest)
            return
        }
        
        do {
            let user = User()
            try user.find(["email": email])
            
            guard user.id > 0 else {
                response.setBody(string: "User not found!")
                        .completed(status: .notFound)
                return
            }
            
            try response.setBody(json: user.asDictionary())
                        .completed(status: .ok)
            
        } catch {
            response.setBody(string: "Database Error")
                    .completed(status: .internalServerError)
        }
    }
    
    func getUserById(request: HTTPRequest, response: HTTPResponse) {
        guard request.hasValidToken() else {
            response.setBody(string: "Unauthenicated user. Please login and try again.")
                    .completed(status: .unauthorized)
            return
        }
        
        guard let idString = request.pathComponents.last, let id = Int(idString) else {
            response.setBody(string: "Missing User Id")
                    .completed(status: .badRequest)
            return
        }
        
        do {
            let user = User()
            try user.get(id)
            
            guard user.id > 0 else {
                response.setBody(string: "User not found!")
                        .completed(status: .notFound)
                return
            }
            
            try response.setBody(json: user.asDictionary())
                    .completed(status: .ok)
            
        } catch {
            response.setBody(string: "Database Error")
                    .completed(status: .internalServerError)
        }
    }
    
    func getAllUsers(request: HTTPRequest, response: HTTPResponse) {
        guard request.hasValidToken() else {
            response.setBody(string: "Unauthenicated user. Please login and try again.")
                    .completed(status: .unauthorized)
            return
        }
        
        do {
            let users = User()
            try users.findAll()
            
            guard users.rows().count > 0 else {
                try response.setBody(json: [String: Any]())
                            .completed(status: .ok)
                return
            }
            
            let json: [[String: Any]] = users.rows().map { (user) -> [String: Any] in
                return user.asDictionary()
            }
            
            try response.setBody(json: json).completed(status: .ok)
            
        } catch {
            response.setBody(string: "Database Error")
                    .completed(status: .internalServerError)
        }
    }
}
