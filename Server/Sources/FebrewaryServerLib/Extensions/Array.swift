//
//  Array.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 6/8/19.
//

import Foundation

extension Array {
    
    /// Creates a comma separated string of `Element` based on the contents of `self`
    ///
    /// - Returns: comma separated string of `Element`
    func toString() -> String {
        var output = String()
        
        for (id, element) in self.enumerated() {
            output.append("\(element)")
            
            if id < self.count - 1 {
                output.append(", ")
            }
        }
        
        return output
    }
}
