//
//  PourerViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 2/2/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class PourerViewController: UIViewController {
    @IBOutlet var beerNameTextField: UITextField!
    @IBOutlet var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        submitButton.layer.cornerRadius = 10
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor.gray.cgColor
    }

    @IBAction func submitTapped(_ sender: Any) {

    }
}
