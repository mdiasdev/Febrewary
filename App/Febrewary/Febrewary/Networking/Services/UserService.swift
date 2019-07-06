//
//  UserService.swift
//  Febrewary
//
//  Created by Matthew Dias on 7/6/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

struct UserService {
    var client: ServiceClient
    
    init(client: ServiceClient = ServiceClient()) {
        self.client = client
    }
    
    func getCurrentUser(completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        let url = URLBuilder(endpoint: .user).buildUrl()
        
        client.get(url: url) { (result) in
            switch result {
            case .success(let response):
                guard let json = response as? JSON else {
                    completionHandler(.failure(UnknownNetworkError()))
                    return
                }
                
                guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                      let user = try? JSONDecoder().decode(User.self, from: data) else {
                        completionHandler(.failure(JSONError()))
                        return
                }
                
                user.save()
                completionHandler(.success(true))
                
            case .failure(let error):
                completionHandler(.failure(error))
            }
            
        }
    }
}
