//
//  VoteViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 8/24/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class VoteViewController: UIViewController, Spinable {

    @IBOutlet weak var containerView: UIView!
    var spinnerView: SpinnerView = SpinnerView.fromNib()
    
    var event: Event!
    var eventBeer: EventBeer? {
        didSet {
            guard let eventBeer = eventBeer else { return }
            Defaults().save(eventBeer: eventBeer)
            DispatchQueue.main.async {
                self.setupVoting(for: eventBeer)
                self.votingVC.hideSpinner()
            }
        }
    }
    
    private var timer: Timer?
    private var votingVC = VotingViewController()
    
    // MARK: - Life Cycle    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let currentEventBeer = Defaults().getCurrentEventBeer() {
            if event.eventBeers.contains(where: { $0.id == currentEventBeer.id }) {
                setupVoting(for: currentEventBeer)
                votingVC.showSpinner(with: "Waiting for next pour.")
            } else {
                Defaults().removeCurrentEventBeer()
            }
            
        } else {
            showSpinner(with: "Fetching data.")
        }

        pollServer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopTimer()
        hideSpinner()
    }
    
    func setupVoting(for eventBeer: EventBeer) {
        if containerView.subviews.count == 0 {
            addVotingSubview()
        }
        
        votingVC.set(eventBeer: eventBeer)
    }
    
    func addVotingSubview() {
        votingVC.event = event
        votingVC.voteDelegate = self
        
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
    
    func showCompletedAlert(error: EventCompleted) {
        let alert = UIAlertController(title: error.title,
                                      message: error.message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismissTapped(self)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Timer
    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(getCurrentBeer), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    // MARK: - Networking
    func pollServer() {
        startTimer()
    }
    
    @objc func getCurrentBeer() {
        let currentEventBeer = Defaults().getCurrentEventBeer()
        EventsService().getCurrentBeer(for: event) { [weak self] result in
            self?.hideSpinner()
            switch result {
            case .success(let eventBeer):
                guard eventBeer.id != currentEventBeer?.id else { return }
                
                self?.eventBeer = eventBeer
                self?.stopTimer()
            case .failure(let error):
                if let eventCompleted = error as? EventCompleted {
                    self?.showCompletedAlert(error: eventCompleted)
                } else {
                    // fail silently
                }
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
