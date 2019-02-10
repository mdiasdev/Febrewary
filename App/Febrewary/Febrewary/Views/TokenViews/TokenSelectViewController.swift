//
//  TokenSelectViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 1/26/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class TokenSelectViewController: UIViewController {

    @IBOutlet var pourerButton: UIButton!
    @IBOutlet var drinkerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: better color choices
        pourerButton.layer.cornerRadius = 10
        pourerButton.layer.borderWidth = 1
        pourerButton.layer.borderColor = UIColor.gray.cgColor

        drinkerButton.layer.cornerRadius = 10
        drinkerButton.layer.borderWidth = 1
        drinkerButton.layer.borderColor = UIColor.gray.cgColor
    }

    @IBAction func tappedIsPourer(_ sender: Any) {
        showNameAlert(type: .pourer)
    }

    @IBAction func tappedIsDrinker(_ sender: Any) {
        showNameAlert(type: .drinker)
    }

    func showNameAlert(type: TokenRequests.TokenType) {
        let alert = UIAlertController(title: "Please Enter Name",
                                      message: "So we can appropriately celebrate you and your winning beer, we'd like to know who we're drinking with tonight",
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your first and last name, please"
        }

        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            guard let drinkerName = alert.textFields?.first?.text, !drinkerName.isEmpty else {
                // FIXME: error handling?
                return
            }

            TokenRequests.getToken(type: type, drinkerName: drinkerName) { (response) in

                guard let token = response["token"] as? String else { return }

                self.save(token: token)
                DispatchQueue.main.async {
                    self.showBeerEntry()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(submitAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    func save(token: String) {
        // FIXME: abstract keys
        UserDefaults.standard.set(token, forKey: "token")
        let expirationDate = Date().addingTimeInterval(86400)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        UserDefaults.standard.set(dateFormatter.string(from: expirationDate), forKey: "tokenExpiration")
    }

    func showBeerEntry() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let enterBeerScreen = storyboard.instantiateViewController(withIdentifier: "EnterBeerScreen")

        self.present(enterBeerScreen, animated: true)
    }
}

// TODO: find a better place for this
struct TokenRequests {
    enum TokenType {
        case drinker
        case pourer
    }

    // TODO: error handling. Result?
    static func getToken(type: TokenType, drinkerName: String? = nil, completion: @escaping ([String: Any]) -> ()) {
        var endpoint = ""
        var query = ""

        switch type {
        case .drinker:
            endpoint = "drinkerToken"
        case .pourer:
            endpoint = "pourerToken"
        }

        if let drinkerName = drinkerName {
            query = "?name=\(drinkerName)"
        }

        // TODO: abstract baseURL
        guard let url = URL(string: "http://localhost:8080/\(endpoint)\(query)") else {
            completion([:])
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                completion([:])
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] else {
                completion([:])
                return
            }

            completion(json ?? [:])
        }

        task.resume()
    }
}
