//
//  AccountViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/18/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.accessibilityIdentifier = "Account container view"

        let signInVC = SignInCreateAccountViewController()
        signInVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(signInVC.view)
        NSLayoutConstraint.activate([
            signInVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            signInVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            signInVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            signInVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
