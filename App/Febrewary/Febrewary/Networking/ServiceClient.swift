//
//  ServiceClient.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/27/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

class ServiceClient {
    
    func post(url: URL, payload: JSON?, completionHandler: @escaping (Result<JSON, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let token = Defaults().getToken() {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
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
                guard let data = data, let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSON else {
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
    
    func put(url: URL, payload: JSON?, completionHandler: @escaping (Result<JSON, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        if let token = Defaults().getToken() {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
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
                guard let data = data, let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSON else {
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
    
    func get(url: URL, completionHandler: @escaping (Result<Any, LocalError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = Defaults().getToken() {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, error == nil else {
                completionHandler(.failure(UnknownNetworkError()))
                return
            }
            
            guard (200..<300).contains(response.statusCode) else {
                completionHandler(.failure(self.localError(from: response, request: request)))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(UnknownNetworkError()))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [JSON] {
                    completionHandler(.success(json))
                } else if let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? JSON {
                    completionHandler(.success(json))
                } else {
                    completionHandler(.failure(JSONError()))
                }
                
            } catch {
                completionHandler(.failure(JSONError()))
            }
        }.resume()
    }
    
    // FIXME: more thorough
    private func localError(from response: HTTPURLResponse, request: URLRequest) -> LocalError {
        switch response.statusCode {
        case 412:
            if (request.url?.absoluteString ?? "").contains("pour") {
                return PourWarning()
            } else {
                return UnknownNetworkError()
            }
        default:
            return JSONError()
        }
    }
}
