//
//  NotificationManager.swift
//  Febrewary
//
//  Created by Matthew Dias on 9/3/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

enum NotificationName: String {
    case loggedIn
    case loggedOut
}

struct NotificationManager {
    
    static func notifyAll(of name: Notification.Name) {
        NotificationCenter.default.post(name: name, object: nil)
    }
}

extension NSNotification.Name {
    static let loggedIn = Notification.Name(NotificationName.loggedIn.rawValue)
    static let loggedOut = Notification.Name(NotificationName.loggedOut.rawValue)
}
