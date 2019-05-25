//
//  SignInCreateAccountViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/18/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class SignInCreateAccountViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var formStackView: UIStackView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupAccessibility()
    }

    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            firstNameTextField.isHidden = true
            lastNameTextField.isHidden = true
        case 1:
            firstNameTextField.isHidden = false
            lastNameTextField.isHidden = false
        default:
            break
        }
    }
    
    
    @IBAction func valueChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            firstNameTextField.isHidden = true
            lastNameTextField.isHidden = true
        case 1:
            firstNameTextField.isHidden = false
            lastNameTextField.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func submit(_ sender: Any) {
    }
    
    func setupAccessibility() {
        view.accessibilityIdentifier = "sign in create account view"
        
        segmentControl.accessibilityIdentifier = "segment control"
        formStackView.accessibilityIdentifier = "form stack view"
        
        firstNameTextField.accessibilityIdentifier = "first name text field"
        lastNameTextField.accessibilityIdentifier = "last name text field"
        emailTextField.accessibilityIdentifier = "email text field"
        passwordTextField.accessibilityIdentifier = "password text field"
    }
}
