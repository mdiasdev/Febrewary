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

public class UserController: RouteController {
    override func initRoutes() {
        routes.add(Route(method: .get, uri: "user", handler: getUser))
        routes.add(Route(method: .get, uri: "user/{id}", handler: getUserById))
    }
    
    // MARK: - Endpoints
    func getUser(request: HTTPRequest, response: HTTPResponse) {
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
}
