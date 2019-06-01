//
//  Cache.swift
//  Febrewary
//
//  Created by Matthew Dias on 6/1/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

class Cache: NSCache<NSString, AnyObject> {
    static let shared = NSCache<NSString, AnyObject>()
}
