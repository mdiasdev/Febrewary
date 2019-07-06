//
//  NetworkErrors.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/27/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

protocol LocalError {
    var title: String { get }
    var message: String { get }
}

public struct JSONError: Error, LocalError {
    var title: String { return "Bad Response" }
    var message: String { return "Could not parse response from server." }
}

public struct UnknownNetworkError: Error, LocalError {
    var title: String { return "Unknown Error" }
    var message: String { return "Could not parse response from server." }
}
