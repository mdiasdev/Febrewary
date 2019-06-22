//
//  DateExtensions.swift
//  Febrewary
//
//  Created by Matthew Dias on 6/16/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

private let formatter = DateFormatter()

extension Date {
    
    var shortMonthDayYear: String {
        formatter.dateFormat = "MMM. d, yyyy"
        
        return formatter.string(from: self)
    }
    
    func isTodayOrFuture() -> Bool {
        let today = Date()
        let todayComponents = Calendar.current.dateComponents([.day, .month, .year], from: today)
        let components = Calendar.current.dateComponents([.day, .month, .year], from: self)
        
        guard todayComponents.year >= components.year else { return true }
        guard todayComponents.month >= components.month else { return true }
        guard todayComponents.day >= components.day else { return true }
        
        return false
    }
}
