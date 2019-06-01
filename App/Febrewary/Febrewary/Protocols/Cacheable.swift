//
//  Cacheable.swift
//  Febrewary
//
//  Created by Matthew Dias on 6/1/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

protocol Cacheable: class {
    var cacheKey: NSString { get }
    
    func save()
}
