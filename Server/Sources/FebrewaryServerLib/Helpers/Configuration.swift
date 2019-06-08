//
//  Configuration.swift
//  FebrewaryServerApp
//
//  Created by Matthew Dias on 6/1/19.
//

import Foundation
import Configuration

struct Configuration {
    private static var path: String {
        #if DEBUG
        return "../../devEnvironment.json"
        #endif
        
        #if RELEASE
        return ""
        #endif
    }
    
    private static var config: ConfigurationManager {
        let config = ConfigurationManager()
        config.load(file: Configuration.path)
        return config
    }
    
    static var dbHost: String {
        return config["database:host"] as! String
    }
    
    static var dbUser: String {
        return config["database:username"] as! String
    }
    
    static var dbPassword: String {
        return config["database:password"] as! String
    }
    
    static var dbName: String {
        return config["database:dbName"] as! String
    }
    
    static var dbPort: Int {
        return config["database:port"] as! Int
    }
    
    static var salt: String {
        return config["security:salt"] as! String
    }
}
