//
//  FakeUserDefaults.swift
//  FebrewaryTests
//
//  Created by Matthew Dias on 6/29/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

@testable import Febrewary

class FakeUserDefaults: Defaults {
    
    override init(userDefaults: UserDefaults = UserDefaults.init(suiteName: "tests")!) {
        super.init(userDefaults: userDefaults)
    }
}
