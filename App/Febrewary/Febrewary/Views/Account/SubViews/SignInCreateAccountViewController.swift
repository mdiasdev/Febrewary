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
//        segmentControl.addTarget(self, action: #selector(didChangeSegment), for: .allTouchEvents)

        setupAccessibility()
    }
    
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
    
    func showFormValidationFailure(for formElement: String) {
        
    }
    
    func attemptRegister(firstName: String, lastName: String, email: String, password: String) {
        // FIXME: abstract URL
        var request = URLRequest(url: URL(string: "http://localhost:8080/register")!)
        let payload = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "password": password
        ]
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("yay")
        }.resume()
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
