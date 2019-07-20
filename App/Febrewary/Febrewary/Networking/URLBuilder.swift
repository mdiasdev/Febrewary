//
//  URLBuilder.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/27/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation


enum Endpoint: String {
    case register = "register"
    case signIn = "login"
    case event = "event"
    case user = "user"
    case beer = "beer"
}

struct URLBuilder {
    let endpoint: Endpoint
    
    private var baseUrl: String {
        return "http://localhost:8080"
    }
    
    func buildUrl() -> URL {
        switch endpoint {
            case .register, .signIn, .event, .user, .beer:
                return URL(string: "\(baseUrl)/\(endpoint.rawValue)")!
        }
    }
}
