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
    
    var eventService = EventsService()
    var event: Event!
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
    
    func showIncompleteAlert() {
        let alert = UIAlertController(title: "Warning!",
                                      message: "Not all votes are in. Are you sure you want to pour the next beer?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Pour Next", style: .default, handler: { _ in
            self.pourNext(shouldForce: true)
        }))
        
        present(alert, animated: true, completion: nil)
    }

    @IBAction func nextTapped(_ sender: Any) {
        pourNext()
    }
    
    func pourNext(shouldForce: Bool = false) {
        eventService.getBeer(for: event, shouldForce: shouldForce) { result in
            switch result {
            case .success(let eventBeer):
                DispatchQueue.main.async {
                    self.eventBeer = eventBeer
                }
            case .failure(let error):
                if error.localizedDescription == "warning" {
                    DispatchQueue.main.async {
                        self.showIncompleteAlert()
                    }
                } else {
                    print("do a thing")
                }
            }
        }
    }
    
}
