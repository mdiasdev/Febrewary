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
            
            DispatchQueue.main.async {
                self.setupVoting(for: self.eventBeer)
            }
        }
    }
    
    private var timer: Timer!
    private var votingVC = VotingViewController()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer(timeInterval: 1, target: self, selector: #selector(getCurrentBeer), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        pollServer()
    }
    
    deinit {
        timer.invalidate()
    }
    
    func setupVoting(for eventBeer: EventBeer) {
        if containerView.subviews.count == 0 {
            addVotingSubview()
        }
        
        votingVC.set(eventBeer: eventBeer)
        votingVC.event = event
        votingVC.voteDelegate = self
    }
    
    func addVotingSubview() {
        votingVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(votingVC.view)
        
        NSLayoutConstraint.activate([
            votingVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            votingVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            votingVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            votingVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        containerView.isHidden = false
    }
    
    // MARK: - Networking
    func pollServer() {
        timer.fire()
    }
    
    @objc func getCurrentBeer() {
        
        EventsService().getCurrentBeer(for: event) { [weak self] result in
            switch result {
            case .success(let eventBeer):
                guard eventBeer.id != self?.eventBeer.id else { return }
                
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

extension VoteViewController: VoteDelegate {
    
    func didVote() {
        pollServer()
    }
}
