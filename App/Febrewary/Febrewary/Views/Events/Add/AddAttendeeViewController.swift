//
//  AddAttendeeViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 8/10/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class AddAttendeeViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var isPourerSwitch: UISwitch!
    @IBOutlet weak var addButton: UIButton!
    
    var event: Event!
    var allUsers = [User]()
    var selectedUser: User?
    let userPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addButton.layer.cornerRadius = 8
        
        userPicker.delegate = self
        userPicker.dataSource = self
        
        nameTextField.inputView = userPicker
        nameTextField.inputAccessoryView = UIToolbar().pickerAccessory(action: #selector(setUser))
        
        if event.pourerId > 0 {
            isPourerSwitch.isUserInteractionEnabled = false
        }
        
        fetchAllUsers()
    }

    // MARK: Actions
    @objc func setUser() {
        let selectedRow = userPicker.selectedRow(inComponent: 0)
        
        guard allUsers.count > selectedRow else { return }
        
        selectedUser = allUsers[selectedRow]
        nameTextField.text = selectedUser?.name
        
        nameTextField.resignFirstResponder()
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        if nameTextField.isFirstResponder {
            nameTextField.resignFirstResponder()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTapped(_ sender: Any) {
        guard let user = selectedUser else {
            showFormError()
            return
        }
        
        add(user: user, to: event, isPourer: isPourerSwitch.isOn)
    }
    
    // MARK: Error Handling
    func showFormError() {
        let alert = UIAlertController(title: "Error!", message: "You must select a user to add", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showSuccessForAdding(user: User, to event: Event) {
        let alert = UIAlertController(title: "Success!",
                                      message: "\(user.name) has been added to \(event.name). Feel free to add more!",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            self.nameTextField.text = nil
            self.isPourerSwitch.setOn(false, animated: true)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showOops() {
        let alert = UIAlertController(title: "Error!", message: "Something went wrong", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Networking
    func fetchAllUsers() {
        UserService().getAll { (result) in
            switch result {
            case .success(let users):
                self.allUsers = users
                DispatchQueue.main.async {
                    self.userPicker.reloadAllComponents()
                }
            case .failure:
                print("failed to get all Users") // TODO: better error handling
            }
        }
    }
    
    func add(user: User, to event: Event, isPourer: Bool) {
        EventsService().add(userId: user.id,
                            isPourer: isPourer,
                            to: event) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.showSuccessForAdding(user: user, to: event)
                case .failure:
                    self.showOops() // TODO: better error handling
                }
            }
        }
    }
    
}

extension AddAttendeeViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard allUsers.count > row else { return nil }
        
        return allUsers[row].name
    }
}

extension AddAttendeeViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allUsers.count
    }
}
