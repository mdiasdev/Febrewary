//
//  VoteViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 8/24/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class VoteViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    private var votingVC = VotingViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func dismissTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
