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
    let datePicker = UIDatePicker()
    private(set) var event: Event?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allTextFields = [nameTextField, dateTextField, addressTextField, pourerTextField, attendeesTextField]
        
        nameTextField.delegate = self
        dateTextField.delegate = self
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = UIToolbar().pickerAccessory(action: #selector(setDate))
        addressTextField.delegate = self
        pourerTextField.delegate = self
        attendeesTextField.delegate = self

        submitButton.layer.cornerRadius = 8
    }
    
    // MARK: - Form
    func isValidateForm() -> Bool {
        return nameTextField.text != nil && nameTextField.text?.isEmpty == false &&
               dateTextField.text != nil && dateTextField.text?.isEmpty == false &&
               addressTextField.text != nil && addressTextField.text?.isEmpty == false &&
               pourerTextField.text != nil && pourerTextField.text?.isEmpty == false &&
               attendeesTextField.text != nil && attendeesTextField.text?.isEmpty == false
    }
    
    func showFormError() {
        let alert = UIAlertController(title: "Error", message: "All form fields are required.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func setDate() {
        dateTextField.text = datePicker.date.shortMonthDayYearWithTime
        _ = textFieldShouldReturn(dateTextField)
    }
    
    // MARK: - Networking
    func createEvent() {
        guard let name = nameTextField.text,
              let address = addressTextField.text,
              let date = dateTextField.text?.toDate() else { return }
        
        let url = URLBuilder(endpoint: .eventsForCurrentUser).buildUrl() // FIXME: change url when networking re-thought out
        let payload: JSON = [
            "name": name,
            "date": date.iso8601,
            "address": address,
            "pourerId": Int(pourerTextField.text!)!, // FIXME: update after #61 and #62
            "attendees": [1,2] // FIXME: update after #61 and #62
        ]
        
        ServiceClient().post(url: url, payload: payload) { result in
            switch result {
            case .success(let eventJson):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                guard let data = try? JSONSerialization.data(withJSONObject: eventJson, options: .prettyPrinted),
                      let event = try? decoder.decode(Event.self, from: data) else {
                        print("bad data")
                        return
                }
                self.event = event
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "unwindToEventsList", sender: self)
                }
            case .failure(let error):
                // fail -> show error
                print("boo")
            }
        }
    }

    // MARK: - Actions
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSubmit(_ sender: Any) {
        if isValidateForm() {
            createEvent()
        } else {
            showFormError()
        }
    }
}

// MARK: - UITextFieldDelegate
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
