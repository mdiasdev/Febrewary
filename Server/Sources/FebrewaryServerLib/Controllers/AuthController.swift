//
//  AuthController.swift
//  COpenSSL
//
//  Created by Matthew Dias on 5/18/19.
//

import Foundation
import PerfectHTTP
import PerfectCrypto
import StORM

class AuthController {
    func register(request: HTTPRequest, response: HTTPResponse, user: User = User()) {
        guard let postBody = try? request.postBodyString?.jsonDecode() as? [String: Any], let json = postBody else {
            response.setBody(string: "Bad Request: malformed json")
                    .completed(status: .badRequest)
            return
        }
        
        do {
            let user = try register(user: user, from: json)
            let token = try prepareToken(user: user)
            let payload: [String: Any] = [
                "token": token,
                "user": user.asDictionary()
            ]
            
            try response.setBody(json: payload)
                        .completed(status: .ok)
            
        } catch _ as MissingPropertyError {
            response.setBody(string: "Bad Request: malformed json")
                    .completed(status: .badRequest)
        } catch _ as UserExistsError {
            response.setBody(string: "User already exists")
                    .completed(status: .badRequest)
        } catch _ as GeneratePasswordError {
            response.setBody(string: "Bad Request: malformed password")
                    .completed(status: .badRequest)
        } catch _ as StORMError {
            response.setBody(string: "Failed to register User")
                    .completed(status: .internalServerError)
        } catch _ as PrepareTokenError {
            response.setBody(string: "Failed to create session")
                    .completed(status: .internalServerError)
        } catch {
            response.completed(status: .internalServerError)
        }
    }
    
    func login(request: HTTPRequest, response: HTTPResponse, user: User = User()) {
        guard let postBody = try? request.postBodyString?.jsonDecode() as? [String: Any], let json = postBody else {
            response.setBody(string: "Bad Request: malformed json")
                    .completed(status: .badRequest)
            return
        }
        
        guard let email = json["email"] as? String, let password = json["password"] as? String else {
            response.setBody(string: "Bad Request: missing property")
                    .completed(status: .badRequest)
            return
        }
        
        do {
            try user.retrieve(["email": email])
            
            guard user.id != 0 else {
                response.setBody(string: "Invalid username or password")
                        .completed(status: .preconditionFailed)
                return
            }
            
            let hashedPassword = try password.generateHash(salt: user.salt)
            
            guard hashedPassword == user.password else {
                response.setBody(string: "Invalid username or password")
                        .completed(status: .preconditionFailed)
                return
            }
            
            let token = try prepareToken(user: user)
            let payload: [String: Any] = [
                "token": token,
                "user": user.asDictionary()
            ]
            
            try response.setBody(json: payload)
                        .completed(status: .ok)
            
        } catch _ as StORMError {
            response.completed(status: .internalServerError)
        } catch _ as GeneratePasswordError {
            response.setBody(string: "Invalid username or password")
                    .completed(status: .preconditionFailed)
        } catch _ as PrepareTokenError {
            response.setBody(string: "Invalid username or password")
                    .completed(status: .preconditionFailed)
        } catch {
            response.completed(status: .internalServerError)
        }
        
    }
    
    // MARK: - Helpers
    
    func register(user: User, from json: [String: Any]) throws -> User {
        guard let firstName = json["firstName"] as? String,
              let lastName = json["lastName"] as? String,
              let email = json["email"] as? String,
              let password = json["password"] as? String else {
                
                throw MissingPropertyError()
        }
        
        try user.retrieve(["email": email])
        
        guard user.id == 0 else {
            throw UserExistsError()
        }
        
        user.firstName = firstName
        user.lastName = lastName
        user.email = email
        user.salt = String.random(length: 14)
        user.password = try password.generateHash(salt: user.salt)
        
        try user.store { id in
            user.id = id as! Int
        }
        
        return user
    }
    
    private func prepareToken(user: User) throws -> String {
        
        let payload: [String : Any] = [
            "email": user.email,
            "issuedAt": Date().timeIntervalSince1970,
            "expiration": Date().addingTimeInterval(36000).timeIntervalSince1970
        ]
        
        guard let jwt = JWTCreator(payload: payload) else {
            throw PrepareTokenError()
        }
        
        let token = try jwt.sign(alg: .hs256, key: Configuration.salt)
        
        return token
    }
}
