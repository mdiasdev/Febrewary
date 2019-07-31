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

class UserController {
    func getCurrentUser(request: HTTPRequest, response: HTTPResponse, user: User = User()) {
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
            try user.retrieve(["email": email])
            
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
    
    func getUserById(request: HTTPRequest, response: HTTPResponse, user: User = User()) {
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
            try user.retrieve(["id": id])
            
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
    
    func getAllUsers(request: HTTPRequest, response: HTTPResponse, users: User = User()) {
        guard request.hasValidToken() else {
            response.setBody(string: "Unauthenicated user. Please login and try again.")
                    .completed(status: .unauthorized)
            return
        }
        
        do {
            try users.getAll()
            
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
