//
//  AccountViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/18/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

protocol AccountDelegate: class {
    func didLogin()
    func didLogout()
}

class AccountViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.accessibilityIdentifier = "Account container view"

        if User().retrieve() != nil {
            didLogin()
        } else {
            didLogout()
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension AccountViewController: AccountDelegate {
    func didLogin() {
        
        if containerView.subviews.count > 0 {
            for subView in containerView.subviews {
                subView.removeFromSuperview()
            }
        }
        
        let userVC = UserViewController()
        userVC.accountDelegate = self
        userVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(userVC.view)
        addChild(userVC)
        NSLayoutConstraint.activate([
            userVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            userVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            userVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            userVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        
        containerView.layoutIfNeeded()
    }
    
    func didLogout() {
        
        if containerView.subviews.count > 0 {
            for subView in containerView.subviews {
                subView.removeFromSuperview()
            }
        }
        
        let signInVC = SignInCreateAccountViewController()
        signInVC.accountDelegate = self
        signInVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(signInVC.view)
        addChild(signInVC)
        NSLayoutConstraint.activate([
            signInVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            signInVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            signInVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            signInVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        containerView.layoutIfNeeded()
    }
}
