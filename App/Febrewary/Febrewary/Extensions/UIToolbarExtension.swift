//
//  UIToolbarExtension.swift
//  Febrewary
//
//  Created by Matthew Dias on 6/22/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

extension UIToolbar {
    
    func pickerAccessory(action: Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Select", style: UIBarButtonItem.Style.plain, target: self, action: action)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}
