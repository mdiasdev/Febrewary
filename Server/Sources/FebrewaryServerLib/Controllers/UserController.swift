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
    func getCurrentUser(request: HTTPRequest, response: HTTPResponse, userDataHandler: UserDataHandler = UserDataHandler()) {
        do {
            let user = try User(request: request)
            let jsonString = try userDataHandler.json(from: user)
            
            response.setBody(string: jsonString)
                    .completed(status: .ok)
            
        } catch is UnauthenticatedError {
            let error = UnauthenticatedError()
            let errorCode = HTTPResponseStatus.statusFrom(code: error.code)
            
            response.setBody(string: error.debugDescription)
                    .completed(status: errorCode)
        } catch {
            response.setBody(string: "Database Error")
                    .completed(status: .internalServerError)
        }
    }
    
    func getUserById(request: HTTPRequest, response: HTTPResponse, userDataHandler: UserDataHandler = UserDataHandler()) {
        guard let idString = request.pathComponents.last, let id = Int(idString) else {
            response.setBody(string: "Missing User Id")
                    .completed(status: .badRequest)
            return
        }
        
        do {
            let user = try User(id: id)
            let jsonString = try userDataHandler.json(from: user)
            
            response.setBody(string: jsonString)
                    .completed(status: .ok)
            
        } catch is UserNotFoundError {
            let error = UserNotFoundError()
            let errorCode = HTTPResponseStatus.statusFrom(code: error.code)
            
            response.setBody(string: error.debugDescription)
                    .completed(status: errorCode)
        } catch {
            response.setBody(string: "Database Error")
                    .completed(status: .internalServerError)
        }
    }
    
    func getAllUsers(request: HTTPRequest, response: HTTPResponse, users: UserDAO = UserDAO()) {
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
