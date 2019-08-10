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
        
        fetchAllUsers()
    }

    @IBAction func closeTapped(_ sender: Any) {
        if nameTextField.isFirstResponder {
            nameTextField.resignFirstResponder()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTapped(_ sender: Any) {
        
    }
    
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
    
    @objc func setUser() {
        let selectedRow = userPicker.selectedRow(inComponent: 0)
        
        guard allUsers.count > selectedRow else { return }
        
        selectedUser = allUsers[selectedRow]
        nameTextField.text = selectedUser?.name
        
        nameTextField.resignFirstResponder()
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
