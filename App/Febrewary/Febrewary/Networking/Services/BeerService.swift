//
//  BeerService.swift
//  Febrewary
//
//  Created by Matthew Dias on 7/20/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

struct BeerService {
    var client: ServiceClient
    
    init(client: ServiceClient = ServiceClient()) {
        self.client = client
    }
    
    func addBeer(named name: String, from brewer: String, abv: Float, completionHandler: @escaping (Result<Beer, Error>) -> Void) {
        let url = URLBuilder(endpoint: .beer).buildUrl()
        
        let payload: JSON = [
            "name": name,
            "brewer": brewer,
            "abv": abv
        ]
        
        client.post(url: url, payload: payload) { result in
            switch result {
            case .success(let beerJson):
                let decoder = JSONDecoder()
                guard let data = try? JSONSerialization.data(withJSONObject: beerJson, options: .prettyPrinted),
                    let event = try? decoder.decode(Beer.self, from: data) else {
                        print("bad data")
                        return
                }
                
                completionHandler(.success(event))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func getBeersForCurrentUser(completionHandler: @escaping (Result<[Beer], Error>) -> Void) {
        let url = URLBuilder(endpoint: .beer).buildUrl()
        
        client.get(url: url) { (result) in
            switch result {
            case .success(let json):
                let decoder = JSONDecoder()
                guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                    let events = try? decoder.decode([Beer].self, from: data) else {
                        print("bad data")
                        return
                }
                completionHandler(.success(events))
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
