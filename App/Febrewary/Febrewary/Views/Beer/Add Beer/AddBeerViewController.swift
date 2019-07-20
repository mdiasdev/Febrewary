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
    @IBOutlet weak var submitButton: UIButton!
    
    var beer: Beer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        submitButton.layer.cornerRadius = 8
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
    
    func showNetworkError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func tappedAddBeer(_ sender: Any) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 1
        
        guard isFormValid(),
            let name = nameTextField.text,
            let brewerName = brewerTextField.text,
            let abvText = abvTextField.text,
            let abv = formatter.number(from: abvText)?.floatValue else {
            showFormError()
            
            return
        }
        
        BeerService().addBeer(named: name, from: brewerName, abv: abv) { result in
            
            DispatchQueue.main.async {
                switch result {
                    case .success:
                        self.performSegue(withIdentifier: "unwindToBeerList", sender: self)
                    case .failure(let error):
                        self.showNetworkError(error: error)
                }
            }
        }
        
    }
}
