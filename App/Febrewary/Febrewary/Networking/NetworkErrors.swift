//
//  NetworkErrors.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/27/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

protocol SomeError {
    var title: String { get }
    var code: Int { get }
    var message: String { get }
}

class LocalError: SomeError, Error {
    var title: String = ""
    var code: Int =  -1
    var message: String = ""
    
    init() { }
}

class JSONError: LocalError {
    override init() {
        super.init()
        
        title = "Bad Response"
        code = 400
        message = "Could not parse response from server."
    }
}

class UnknownNetworkError: LocalError {
    override init() {
        super.init()
        
        title = "Unknown Error"
        code = 500
        message = "Could not parse response from server."
    }
}

class PourWarning: LocalError {
    override init() {
        super.init()
        
        title = "Warning!"
        code = 412
        message = "Not all votes are in. Are you sure you want to pour the next beer?"
    }
}

class EventCompleted: LocalError {
    override init() {
        super.init()
        
        title = "Event is over"
        code = 204
        message = "All votes are in and the event is over"
    }
}
