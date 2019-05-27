//
//  SignInCreateAccountViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/18/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class SignInCreateAccountViewController: UIViewController {
    
    enum Segment: Int {
        case signIn = 0
        case createAccount = 1
    }
    typealias FormFields = (firstName: String, lastName: String, email: String, password: String)

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var formStackView: UIStackView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupAccessibility()
        updateForm(for: .signIn)
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
    
    func updateForm(for segment: Segment) {
        switch segment
        {
        case .signIn:
            firstNameTextField.isHidden = true
            lastNameTextField.isHidden = true
        case .createAccount:
            firstNameTextField.isHidden = false
            lastNameTextField.isHidden = false
        }
    }
    
    // MARK: - Actions
    @IBAction func didChange(_ sender: UISegmentedControl) {
        guard let segment = Segment(rawValue: sender.selectedSegmentIndex) else {
            assertionFailure("unsupported segment")
            return
        }
        
        updateForm(for: segment)
    }
    
    @IBAction func submit(_ sender: Any) {
        
        guard let segment = Segment(rawValue: segmentControl.selectedSegmentIndex) else { return }
        
        switch segment {
        case .signIn:
            let formValidation = isFormValid(for: .signIn)
            
            guard formValidation.isValid, let formFields = formValidation.fields else { return }
            
            signIn(email: formFields.email, password: formFields.password)
        case .createAccount:
            let formValidation = isFormValid(for: .createAccount)
            
            guard formValidation.isValid, let formFields = formValidation.fields else { return }
            
            register(firstName: formFields.firstName,
                     lastName: formFields.lastName,
                     email: formFields.email,
                     password: formFields.password)
        }
    }
    
    // MARK: - Error Handling
    func isFormValid(for segment: Segment) -> (isValid: Bool, fields: FormFields?) {
        switch segment {
        case .signIn:
            guard let email = emailTextField.text, !email.isEmpty else {
                showFormValidationFailure(for: "Email")
                return (false, nil)
            }
            
            guard let password = passwordTextField.text, !password.isEmpty else {
                showFormValidationFailure(for: "Password")
                return (false, nil)
            }
            return (true, ("", "", email, password))
        case .createAccount:
            guard let firstName = firstNameTextField.text, !firstName.isEmpty else {
                showFormValidationFailure(for: "First Name")
                return (false, nil)
            }
            
            guard let lastName = lastNameTextField.text, !lastName.isEmpty else {
                showFormValidationFailure(for: "Last Name")
                return (false, nil)
            }
            
            guard let email = emailTextField.text, !email.isEmpty else {
                showFormValidationFailure(for: "Email")
                return (false, nil)
            }
            
            guard let password = passwordTextField.text, !password.isEmpty else {
                showFormValidationFailure(for: "Password")
                return (false, nil)
            }
            
            return (true, (firstName, lastName, email, password))
        }
    }
    
    func showFormValidationFailure(for formElement: String) {
        let alert = UIAlertController(title: "Missing Information!", message: "\(formElement) must have a value", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Networking
    func register(firstName: String, lastName: String, email: String, password: String) {
        let url = URLBuilder(endpoint: .register).buildUrl()
        let payload = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "password": password
        ]
        
        ServiceClient().post(url: url, payload: payload) { result in
            // TODO: save token and user
        }
    }
    
    func signIn(email: String, password: String) {
        
    }
}
