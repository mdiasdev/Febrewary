//
//  EnterBeerViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 2/2/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class EnterBeerViewController: UIViewController {
    @IBOutlet var beerNameTextField: UITextField!
    @IBOutlet var brewerNameTextField: UITextField!
    @IBOutlet var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        submitButton.layer.cornerRadius = 10
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor.gray.cgColor
    }

    @IBAction func submitTapped(_ sender: Any) {
        guard let beerName = beerNameTextField.text, !beerName.isEmpty else {
            presentFormError(missing: "beer name")
            return
        }

        guard let brewerName = brewerNameTextField.text, !brewerName.isEmpty else {
            presentFormError(missing: "brewer name")
            return
        }

        add(beer: beerName, madeBy: brewerName) { error in
            // FIXME: error handling
        }
    }

    func presentFormError(missing value: String) {
        let alert = UIAlertController(title: "Error: Missing Value",
                                      message: "You forgot to enter the \(value) which is required",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    func add(beer beerName: String, madeBy brewerName: String, completion: @escaping (Error?) -> Void) {
        // FIXME: abstract baseUrl
        guard let url = URL(string: "http://localhost:8080/beer") else {
            let error = NetworkingError(code: -50, description: "bad url")
            completion(error)
            return
        }

        let postBody: [String: String] = [
            "beerName": beerName,
            "brewerName": brewerName
        ]

        guard let postData = try? JSONSerialization.data(withJSONObject: postBody, options: .prettyPrinted) else {
            let error = NetworkingError(code: -50, description: "bad payload")
            completion(error)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "token")
        request.httpBody = postData

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(error!)
                return
            }
        }.resume()
    }
}

struct NetworkingError: Error {
    var code: Int
    var description: String
}
