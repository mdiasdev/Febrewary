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
    
    func setupAccessibility() {
        view.accessibilityIdentifier = "sign in create account view"
        
        segmentControl.accessibilityIdentifier = "segment control"
        formStackView.accessibilityIdentifier = "form stack view"
        
        firstNameTextField.accessibilityIdentifier = "first name text field"
        lastNameTextField.accessibilityIdentifier = "last name text field"
        emailTextField.accessibilityIdentifier = "email text field"
        passwordTextField.accessibilityIdentifier = "password text field"
    }
    
    // MARK: - Actions
    @IBAction func didChangeSegment() {

        switch segmentControl.selectedSegmentIndex
        {
            case 0:
                firstNameTextField.isHidden = true
                lastNameTextField.isHidden = true
            case 1:
                firstNameTextField.isHidden = false
                lastNameTextField.isHidden = false
            default:
                assertionFailure("unimplemented segment")
        }
    }
    
    @IBAction func submit(_ sender: Any) {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty else {
            showFormValidationFailure(for: "First Name")
            return
        }
        
        guard let lastName = lastNameTextField.text, !lastName.isEmpty else {
            showFormValidationFailure(for: "Last Name")
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showFormValidationFailure(for: "Email")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showFormValidationFailure(for: "Password")
            return
        }
        
        attemptRegister(firstName: firstName, lastName: lastName, email: email, password: password)
    }
    
    // MARK: Error Handling
    func showFormValidationFailure(for formElement: String) {
        
    }
    
    // MARK: Netowrking
    func attemptRegister(firstName: String, lastName: String, email: String, password: String) {
        let url = URLBuilder(endpoint: .register).buildUrl()
        let payload = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "password": password
        ]
        
        ServiceClient().post(url: url, payload: payload) { result in
            
        }
    }
}
