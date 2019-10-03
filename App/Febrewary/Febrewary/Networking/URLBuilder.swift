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
    case users = "users"
    case beer = "beer"
    case beerSearch = "beer/search"
}

struct URLBuilder {
    let endpoint: Endpoint
    
    private var baseUrl: String {
        return "http://localhost:8080"
    }
    
    func buildUrl(components: [(name: String, value: String)] = []) -> URL {
        var url = URLComponents(string: "\(baseUrl)/\(endpoint.rawValue)")
    
        if components.count > 0 {
            url?.queryItems = []
        }
    
        for component in components {
            let queryItem = URLQueryItem(name: component.name, value: component.value)
            url?.queryItems?.append(queryItem)
        }
    
        return url!.url!
    }
}
