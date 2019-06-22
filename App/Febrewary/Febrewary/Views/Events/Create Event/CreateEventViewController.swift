//
//  CreateEventViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 6/22/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var pourerTextField: UITextField!
    @IBOutlet weak var attendeesTextField: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    var allTextFields = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allTextFields = [nameTextField, dateTextField, addressTextField, pourerTextField, attendeesTextField]
        
        nameTextField.delegate = self
        dateTextField.delegate = self
        addressTextField.delegate = self
        pourerTextField.delegate = self
        attendeesTextField.delegate = self

        submitButton.layer.cornerRadius = 8
    }

    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension CreateEventViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let id = allTextFields.firstIndex(where: { return $0 == textField }) else {
            return true
        }
        
        let nextId = allTextFields.index(after: id)
        
        if allTextFields.count > nextId {
            let nextfield = allTextFields[nextId]
            nextfield.becomeFirstResponder()
        } else if allTextFields.count == nextId, let lastfield = allTextFields.last {
            lastfield.resignFirstResponder()
        }
        
        return true
    }
}
