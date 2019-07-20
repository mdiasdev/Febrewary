//
//  AddBeerViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 7/20/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class AddBeerViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var brewerTextField: UITextField!
    @IBOutlet weak var abvTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func isFormValid() -> Bool {
        return nameTextField.text?.isEmpty == false &&
               brewerTextField.text?.isEmpty == false &&
               abvTextField.text?.isEmpty == false &&
               Double(abvTextField.text ?? "") > 0
    }
    
    func showFormError() {
        let alert = UIAlertController(title: "Error", message: "A beer must have a name, brewer, and ABV higher than 0.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func tappedAddBeer(_ sender: Any) {
        guard isFormValid() else {
            showFormError()
            
            return
        }
        
        
    }
}
