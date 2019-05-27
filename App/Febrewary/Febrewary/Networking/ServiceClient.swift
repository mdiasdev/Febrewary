//
//  ServiceClient.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/27/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

struct ServiceClient {
    func get(url: URL) {
        assertionFailure("still need to build this")
    }
    
    func post(url: URL, payload: JSON?, completionHandler: @escaping (Result<JSON, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let payload = payload {
            request.httpBody = try? JSONSerialization.data(withJSONObject: payload,
                                                           options: .prettyPrinted)
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completionHandler(.failure(error!))
                return
            }
            
            do {
                guard let data = data, let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? JSON else {
                    completionHandler(.failure(JSONError()))
                    return
                }
                
                completionHandler(.success(json))
            } catch {
                completionHandler(.failure(JSONError()))
                return
            }
            
        }.resume()
    }
}
