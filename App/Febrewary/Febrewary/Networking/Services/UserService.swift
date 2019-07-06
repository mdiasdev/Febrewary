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
        
//        client.get(url: url) { (result) in
//            AuthService().handle(result: result, completion: { error in
//                if error == nil {
//                    completionHandler(.success(true))
//                } else {
//                    completionHandler(.failure(error!))
//                }
//            })
//        }
    }
}
