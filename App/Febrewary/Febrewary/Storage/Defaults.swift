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
        case eventBeerId
    }
    
    private var userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Auth Token
    func save(token: String) {
        userDefaults.set(token, forKey: Keys.token.rawValue)
    }
    
    func getToken() -> String? {
        return userDefaults.object(forKey: Keys.token.rawValue) as? String
    }
    
    func removeToken() {
        userDefaults.removeObject(forKey: Keys.token.rawValue)
    }
    
    // MARK: EventBeer
    func save(eventBeer: EventBeer) {
        guard let eventBeerData = try? JSONEncoder().encode(eventBeer) else { return }
    
        userDefaults.set(eventBeerData, forKey: Keys.eventBeerId.rawValue)
    }
    
    func getCurrentEventBeer() -> EventBeer? {
        guard let data = userDefaults.object(forKey: Keys.eventBeerId.rawValue) as? Data else { return nil }
        return try? JSONDecoder().decode(EventBeer.self, from: data)
    }
    
    func removeCurrentEventBeer() {
        userDefaults.removeObject(forKey: Keys.eventBeerId.rawValue)
    }
}
