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
    typealias FormFields = (name: String, email: String, password: String)

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var formStackView: UIStackView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    weak var accountDelegate: AccountDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.cornerRadius = 22
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        submitButton.layer.cornerRadius = 8
        
        setupAccessibility()
        updateForm(for: .signIn)
    }
    
    func setupAccessibility() {
        view.accessibilityIdentifier = "sign in create account view"
        
        segmentControl.accessibilityIdentifier = "segment control"
        formStackView.accessibilityIdentifier = "form stack view"
        
        nameTextField.accessibilityIdentifier = "name text field"
        emailTextField.accessibilityIdentifier = "email text field"
        passwordTextField.accessibilityIdentifier = "password text field"
    }
    
    func updateForm(for segment: Segment) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            switch segment
            {
            case .signIn:
                self?.nameTextField.isHidden = true
            case .createAccount:
                self?.nameTextField.isHidden = false
            }
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
            
            register(name: formFields.name,
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
            return (true, ("", email, password))
        case .createAccount:
            guard let name = nameTextField.text, !name.isEmpty else {
                showFormValidationFailure(for: "Name")
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
            
            return (true, (name, email, password))
        }
    }
    
    func showFormValidationFailure(for formElement: String) {
        let alert = UIAlertController(title: "Missing Information!", message: "\(formElement) must have a value", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Networking
    func register(name: String, email: String, password: String) {
        AuthService().createAccount(name: name, email: email, password: password) { [weak self] result in
            self?.handle(result: result)
        }
    }
    
    func signIn(email: String, password: String) {
        AuthService().signIn(email: email, password: password) { [weak self] result in
            self?.handle(result: result)
        }
        
    }
    
    func handle(result: Result<Bool, Error>) {
        switch result {
        case .success:
            DispatchQueue.main.async {
                self.accountDelegate?.didLogin()
            }
        case .failure(let error):
            guard let localError = error as? LocalError else { return }
            
            let alert = UIAlertController(title: localError.title, message: localError.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
