//
//  VotingViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 8/24/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class VotingViewController: UIViewController {
    
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var submitButton: UIButton!
    
    var score = 1
    var eventBeer: EventBeer! {
        didSet {
            roundLabel.text = "Round \(eventBeer.round)"
            slider.value = 1
            scoreLabel.text = "1"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        submitButton.layer.cornerRadius = 8
    }

    @IBAction func submitTapped(_ sender: Any) {
    }
    
    @IBAction func setValue(_ sender: UISlider) {
        score = Int(round(sender.value))
        scoreLabel.text = "\(score)"
        sender.setValue(Float(score), animated: true)
    }
}
