//
//  PouringViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 8/17/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class PouringViewController: UIViewController {

    @IBOutlet weak var labelContainerView: UIView!
    @IBOutlet weak var beerNameLabel: UILabel!
    @IBOutlet weak var brewerNameLabel: UILabel!
    @IBOutlet weak var attendeeNameLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    var eventService = EventsService()
    var event: Event!
    var eventBeer: EventBeer? {
        didSet {
            guard let eventBeer = eventBeer else { return }
            
            labelContainerView.isHidden = false
            setupLabels(with: eventBeer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nextButton.layer.cornerRadius = 8
        labelContainerView.isHidden = true
    }
    
    func setupLabels(with eventBeer: EventBeer) {
        beerNameLabel.text = eventBeer.beer.name
        brewerNameLabel.text = eventBeer.beer.brewerName
        attendeeNameLabel.text = eventBeer.attendee.name
    }
    
    func showIncompleteAlert(error: PourWarning) {
        let alert = UIAlertController(title: error.title,
                                      message: error.message,
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
        eventService.getBeer(for: event, shouldForce: shouldForce) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let eventBeer):
                    self?.eventBeer = eventBeer
                case .failure(let error):
                    if let warning = error as? PourWarning {
                        self?.showIncompleteAlert(error: warning)
                    }
                }
            }
        }
    }
    
}
