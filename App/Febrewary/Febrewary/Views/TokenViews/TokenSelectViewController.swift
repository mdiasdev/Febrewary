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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = UserDefaults.standard.string(forKey: "token") {
            let alert = UIAlertController(title: "Good Job", message: "you have a token:\n \(token)", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func tappedIsPourer(_ sender: Any) {
        // hit backend to get token
        // save token
        // save current time
        TokenRequests.getToken(type: .pourer) { (response) in
            guard let token = response["pourerToken"] as? String else { return }

            self.save(token: token)
        }
    }

    @IBAction func tappedIsDrinker(_ sender: Any) {
        // hit backend to get token
        // save token
        // save current time
        TokenRequests.getToken(type: .drinker) { (response) in
            guard let token = response["drinkerToken"] as? String else { return }

            self.save(token: token)
        }
    }

    func save(token: String) {
        // FIXME: abstract keys
        UserDefaults.standard.set(token, forKey: "token")
        UserDefaults.standard.set(Date().addingTimeInterval(86400), forKey: "tokenExpiration")
    }
}

// TODO: find a better place for this
struct TokenRequests {
    enum TokenType {
        case drinker
        case pourer
    }

    // TODO: error handling. Result?
    static func getToken(type: TokenType, completion: @escaping ([String: Any]) -> ()) {
        var endpoint = ""
        switch type {
        case .drinker:
            endpoint = "drinkerToken"
        case .pourer:
            endpoint = "pourerToken"
        }

        // TODO: abstract baseURL
        guard let url = URL(string: "http://localhost:8080/\(endpoint)") else {
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
