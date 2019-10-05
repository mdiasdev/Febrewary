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
            response.completed(with: UnauthenticatedError())
        } catch {
            response.completed(with: DatabaseError())
        }
    }
    
    func getUserById(request: HTTPRequest, response: HTTPResponse, userDataHandler: UserDataHandler = UserDataHandler()) {
        guard let idString = request.pathComponents.last, let id = Int(idString) else {
            response.completed(with: MalformedRequestError())
            return
        }
        
        do {
            let user = try User(id: id)
            let jsonString = try userDataHandler.json(from: user)
            
            response.setBody(string: jsonString)
                    .completed(status: .ok)
            
        } catch is UserNotFoundError {
            response.completed(with: UserNotFoundError())
        } catch {
            response.completed(with: DatabaseError())
        }
    }
    
    func getAllUsers(request: HTTPRequest, response: HTTPResponse, userDataHandler: UserDataHandler = UserDataHandler()) {
        do {
            let users = try userDataHandler.getAllUsers()
            let json: [String] = users.compactMap { try? userDataHandler.json(from: $0) }
            
            response.setBody(string: "[\(json.toString())]")
                    .completed(status: .ok)
            
        } catch {
            response.completed(with: DatabaseError())
        }
    }
}
