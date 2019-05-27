//
//  NetworkErrors.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/27/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

public struct JSONError: Error {
    let title = "Bad Response"
    let message = "Could not parse response from server."
}
