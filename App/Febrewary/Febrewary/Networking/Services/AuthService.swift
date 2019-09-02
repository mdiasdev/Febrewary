//
//  AuthService.swift
//  Febrewary
//
//  Created by Matthew Dias on 6/29/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

struct AuthService {
    var client: ServiceClient
    var userDefaults: Defaults
    
    init(client: ServiceClient = ServiceClient(), defaults: Defaults = Defaults()) {
        self.client = client
        self.userDefaults = defaults
    }
    
    func signIn(email: String, password: String, completionHandler: @escaping (Result<Bool, LocalError>) -> Void) {
        
        let url = URLBuilder(endpoint: .signIn).buildUrl()
        let payload = [
            "email": email,
            "password": password
        ]
        
        client.post(url: url, payload: payload) { result in
            switch result {
            case .success:
                self.handle(result: result) { error in
                    guard let error = error else {
                        completionHandler(.success(true))
                        return
                    }
                 
                    completionHandler(.failure(error))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func createAccount(name: String, email: String, password: String, completionHandler: @escaping (Result<Bool, LocalError>) -> Void) {
        let url = URLBuilder(endpoint: .register).buildUrl()
        let payload = [
            "name": name,
            "email": email,
            "password": password
        ]
        
        client.post(url: url, payload: payload) { result in
            switch result {
            case .success:
                self.handle(result: result) { error in
                    guard let error = error else {
                        completionHandler(.success(true))
                        return
                    }
                    
                    completionHandler(.failure(error))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
            
        }
    }
    
    func handle(result: Result<JSON, LocalError>, completion: @escaping (LocalError?) -> Void) {
        switch result {
        case .success(let response):
            guard let userJson = response["user"] as? JSON,
                let data = try? JSONSerialization.data(withJSONObject: userJson, options: .prettyPrinted),
                let user = try? JSONDecoder().decode(User.self, from: data),
                let token = response["token"] as? String else {
                    completion(JSONError())
                    return
            }
            
            user.save()
            userDefaults.save(token: token)
            completion(nil)
        case .failure:
            return
        }
    }
}
