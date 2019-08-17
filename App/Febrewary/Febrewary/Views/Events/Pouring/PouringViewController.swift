//
//  PouringViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 8/17/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class PouringViewController: UIViewController {

    @IBOutlet weak var beerNameLabel: UILabel!
    @IBOutlet weak var brewerNameLabel: UILabel!
    @IBOutlet weak var attendeeNameLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    var eventBeer: EventBeer? {
        didSet {
            guard let eventBeer = eventBeer else { return }
            
            setupLabels(with: eventBeer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nextButton.layer.cornerRadius = 8
    }
    
    func setupLabels(with eventBeer: EventBeer) {
        beerNameLabel.text = eventBeer.beer.name
        brewerNameLabel.text = eventBeer.beer.brewerName
        attendeeNameLabel.text = eventBeer.attendee.name
    }

    @IBAction func nextTapped(_ sender: Any) {
        
    }
    
    func pourNext(shouldForce: Bool = false) {
        
    }
    
}
