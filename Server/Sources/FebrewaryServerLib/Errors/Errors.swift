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

public struct MalformedRequestError: ServerError {
    var title: String = "Malformed Request"
    var message: String = "Missing a required query parameter."
    var code: Int = 400
}

public struct MalformedJSONError: ServerError {
    var title: String = "Malformed Request JSON"
    var message: String = "Unable to parse JSON."
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

public struct DatabaseError: ServerError {
    var title: String = "Internal Error"
    var message: String = "Something went wrong."
    var code: Int = 500
}

public struct EventNotFoundError: ServerError {
    var title: String = "Event Not Found"
    var message: String = "An Event with this ID could not be found."
    var code: Int = 404
}

public struct UserNotInvitedError: ServerError {
    var title: String = "User Not Invited"
    var message: String = "This user has not yet been invited to this event."
    var code: Int = 404
}

public struct EventBeerExistsError: ServerError {
    var title: String = "Cannot Add Beer to Event"
    var message: String = "This User has already added a Beer to this Event."
    var code: Int = 403
}
