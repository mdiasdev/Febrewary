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
    
    var event: Event!
    var eventBeer: EventBeer! {
        didSet {
            guard eventBeer != nil else { return }
            
            votingVC.eventBeer = eventBeer
            containerView.isHidden = false
        }
    }
    
    private var timer = Timer(timeInterval: 15, target: self, selector: #selector(getCurrentBeer), userInfo: nil, repeats: true)
    private var votingVC = VotingViewController()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    deinit {
        timer.invalidate()
    }
    
    // MARK: - Networking
    func pollServer() {
        timer.fire()
    }
    
    @objc func getCurrentBeer() {
        
        EventsService().getCurrentBeer(for: event) { [weak self] result in
            switch result {
            case .success(let eventBeer):
                self?.eventBeer = eventBeer
                self?.timer.invalidate()
            case .failure: break // fail silently
            }
        }
    }

    // MARK: - Actions
    @IBAction func dismissTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
