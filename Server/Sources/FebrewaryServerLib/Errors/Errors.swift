//
//  Errors.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 5/18/19.
//

import Foundation

typealias ErrorJSON = [String: Any]

protocol ServerError: Error, Codable, Equatable {
    var title: String { get }
    var message: String  { get }
    var code: Int { get }
    func asJson() -> ErrorJSON
}

extension ServerError {
    func asJson() -> ErrorJSON {
        return [
            "title": title,
            "message": message,
            "code": code
        ]
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
