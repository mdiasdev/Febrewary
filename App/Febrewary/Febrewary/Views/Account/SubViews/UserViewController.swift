//
//  UserViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 6/1/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    weak var accountDelegate: AccountDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let user = User().retrieve() else { return }
        
        nameLabel.text = "\(user.name)"
        
        view.layer.cornerRadius = 22
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        logoutButton.layer.cornerRadius = 8
    }

    @IBAction func logOut(_ sender: Any) {
        Cache.shared.removeAllObjects()
        Defaults().removeToken()
        
        DispatchQueue.main.async { [weak self] in
            self?.accountDelegate?.didLogout()
        }
    }
    
}
