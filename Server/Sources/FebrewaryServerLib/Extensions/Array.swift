//
//  Array.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 6/8/19.
//

import Foundation

extension Array {
    func toString() -> String {
        var temp = String()
        
        for item in self {
            temp.append(", \(item)")
        }
        
        let output = temp.dropFirst(2)
        
        return String(output)
    }
}
