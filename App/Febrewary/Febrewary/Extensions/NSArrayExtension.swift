//
//  NSArrayExtension.swift
//  Febrewary
//
//  Created by Matthew Dias on 7/27/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

extension NSArray: Cacheable {
    var cacheKey: NSString {
        return String(describing: Element.self) as NSString
    }
    
    func save() {
        Cache.shared.setObject(self, forKey: cacheKey)
    }
    
    func retrieve() -> NSArray? {
        return Cache.shared.object(forKey: cacheKey) as? NSArray
    }
}
