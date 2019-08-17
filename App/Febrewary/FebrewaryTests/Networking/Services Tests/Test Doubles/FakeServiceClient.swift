//
//  FakeServiceClient.swift
//  FebrewaryTests
//
//  Created by Matthew Dias on 6/29/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

@testable import Febrewary

class FakeServiceClient: ServiceClient {
    var successFileName: String?
    var errorFileName: String?
    
    override func get(url: URL, completionHandler: @escaping (Result<Any, LocalError>) -> Void) {
        if let successFileName = self.successFileName {
            if let json = json(fromFile: successFileName) {
                completionHandler(.success(json))
                return
            }
            
            let json = jsonArray(fromFile: successFileName)
            
            guard json.count > 0 else {
                assertionFailure("bad file name")
                return
            }
            
            completionHandler(.success(json))
        } else if let errorFileName = self.errorFileName {
            // FIXME: error from file?
            completionHandler(.failure(JSONError()))
        } else {
            assertionFailure("forgot to stub the call to: \(url)")
        }
    }
    
    override func post(url: URL, payload: JSON?, completionHandler: @escaping (Result<JSON, Error>) -> Void) {
        if let successFileName = self.successFileName {
            guard let json = json(fromFile: successFileName) else {
                assertionFailure("bad file name")
                return
            }
            completionHandler(.success(json))
        } else if let errorFileName = self.errorFileName {
            // FIXME: error from file?
            completionHandler(.failure(JSONError()))
        } else {
            assertionFailure("forgot to stub the call to: \(url)")
        }
    }
    
    func json(fromFile fileName: String) -> JSON? {
        guard let path = Bundle(for: FakeServiceClient.self).path(forResource: fileName, ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
              let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? JSON else { return nil }
        
        return json
    }
    
    func jsonArray(fromFile fileName: String) -> [JSON] {
        
        guard let path = Bundle(for: FakeServiceClient.self).path(forResource: fileName, ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
              let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [JSON],
              json != nil else { return [] }
        
        return json!
    }
}
