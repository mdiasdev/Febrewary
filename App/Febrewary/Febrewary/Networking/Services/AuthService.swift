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
    
    init(client: ServiceClient = ServiceClient()) {
        self.client = client
    }
    
    func signIn(email: String, password: String, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        
        let url = URLBuilder(endpoint: .signIn).buildUrl()
        let payload = [
            "email": email,
            "password": password
        ]
        
        ServiceClient().post(url: url, payload: payload) { result in
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
    
    private func handle(result: Result<JSON, Error>, completion: @escaping (Error?) -> Void) {
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
            Defaults().save(token: token)
            completion(nil)
        case .failure:
            return
        }
    }
}
