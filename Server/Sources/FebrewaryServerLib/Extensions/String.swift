//
//  String.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 5/18/19.
//

import Foundation

extension String {
    func generateHash(salt: String) throws -> String {
        let stringWithSalt = salt + self
        
        guard let stringArray = stringWithSalt.digest(.sha256)?.encode(.base64) else {
            throw GeneratePasswordError()
        }
        
        guard let stringHash = String(data: Data(bytes: stringArray, count: stringArray.count), encoding: .utf8) else {
            throw GeneratePasswordError()
        }
        
        return stringHash
    }
    
    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
