//
//  VotingViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 8/24/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

protocol VoteDelegate: class {    
    func didVote()
}

class VotingViewController: UIViewController, Spinable {
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var submitButton: UIButton!
    
    var spinnerView: SpinnerView = SpinnerView.fromNib()
    weak var voteDelegate: VoteDelegate?
    var score = 1
    var event: Event!
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
    
    func set(eventBeer: EventBeer) {
        self.eventBeer = eventBeer
        // hide spinner
    }

    @IBAction func submitTapped(_ sender: Any) {
        showSpinner(with: "Waiting for next pour.")
        EventsService().vote(score: score, for: eventBeer, in: event) { [weak self] result in
            switch result {
            case .success:
                self?.voteDelegate?.didVote()
            case .failure(let error):
                // TODO: better error handling
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func setValue(_ sender: UISlider) {
        score = Int(round(sender.value))
        scoreLabel.text = "\(score)"
        sender.setValue(Float(score), animated: true)
    }
}
