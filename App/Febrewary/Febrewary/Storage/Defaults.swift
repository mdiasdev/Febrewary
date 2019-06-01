//
//  Defaults.swift
//  Febrewary
//
//  Created by Matthew Dias on 6/1/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

class Defaults {
    
    private enum Keys: String {
        case token
    }
    
    private var userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    func save(token: String) {
        userDefaults.set(token, forKey: Keys.token.rawValue)
    }
    
    func getToken() -> String? {
        return userDefaults.object(forKey: Keys.token.rawValue) as? String
    }
    
    func removeToken() {
        userDefaults.removeObject(forKey: Keys.token.rawValue)
    }
}
