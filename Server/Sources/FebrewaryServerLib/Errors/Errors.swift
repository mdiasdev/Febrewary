//
//  Errors.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 5/18/19.
//

import Foundation

protocol ServerError: Error, Codable, Equatable, CustomDebugStringConvertible {
    var title: String { get }
    var message: String  { get }
    var code: Int { get }
    func asJson() throws -> String
}

extension ServerError {
    func asJson() throws -> String {
        let jsonData = try JSONEncoder().encode(self)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw UnknownError()
        }
        
        return jsonString
    }
    
    public var debugDescription: String {
        return """
                {
                    title: \(self.title),
                    message: \(self.message),
                    code: \(self.code)
                }
               """
    }
}

public struct GeneratePasswordError: ServerError {
    var title: String = "Invalid username or password"
    var message: String = "Invalid username or password."
    var code: Int = 400
}

public struct MissingPropertyError: ServerError {
    var title: String = "Missing request property"
    var message: String = "One or more properties are missing."
    var code: Int = 400
}

public struct MissingQueryError: ServerError {
    var title: String = "Missing request query"
    var message: String = "Search terms needed."
    var code: Int = 400
}

public struct PrepareTokenError: ServerError {
    var title: String = "Unauthenticated"
    var message: String = "Failed to create authenticated session."
    var code: Int = 500
}

public struct UserExistsError: ServerError {
    var title: String = "Failed to register"
    var message: String = "This email is already in use."
    var code: Int = 400
}

public struct UserNotFoundError: ServerError {
    var title: String = "Failed to find User"
    var message: String = "This user does not exist."
    var code: Int = 404
}

public struct UnauthenticatedError: ServerError {
    var title: String = "Unauthenticated"
    var message: String = "Could not authenticate user."
    var code: Int = 401
}

public struct BadTokenError: ServerError {
    var title: String = "Bad Auth Token"
    var message: String = "The auth token used is malformed."
    var code: Int = 400
}

public struct UnknownError: ServerError {
    var title: String = "Unknown Error"
    var message: String = "Something went wrong."
    var code: Int = 500
}
