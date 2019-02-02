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
    @IBOutlet var drinkerNameTextField: UITextField!
    @IBOutlet var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        submitButton.layer.cornerRadius = 10
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor.gray.cgColor
    }

    @IBAction func submitTapped(_ sender: Any) {
        guard let beerName = beerNameTextField.text, !beerName.isEmpty else {
            presentFormError(missing: "beer name")
            return
        }

        guard let drinkerName = drinkerNameTextField.text, !drinkerName.isEmpty else {
            presentFormError(missing: "drinker name")
            return
        }
    }

    func presentFormError(missing value: String) {
        let alert = UIAlertController(title: "Error: Missing Value",
                                      message: "You forgot to enter the \(value) which is required",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}
