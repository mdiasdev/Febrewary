//
//  EventsViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/18/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!

    var transition = TopDownAnimator()
    let noEventsView = Bundle.main.loadNibNamed("NoEventsView", owner: self, options: nil)?.first as! NoEventsView // FIXME: no force unwrapping
    let eventsTable = EventsTableViewController()
    
    private var upcommingEvents = [Event]() {
        didSet {
            eventsTable.upcommingEvents = upcommingEvents
            (upcommingEvents as NSArray).save()
        }
    }
    private var pastEvents = [Event]() {
        didSet {
            eventsTable.pastEvents = pastEvents
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        eventsTable.navigationDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .loggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearData), name: .loggedOut, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        noEventsView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(noEventsView)
        NSLayoutConstraint.activate([
            noEventsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            noEventsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            noEventsView.topAnchor.constraint(equalTo: containerView.topAnchor),
            noEventsView.heightAnchor.constraint(greaterThanOrEqualToConstant: 111.5),
        ])
        
        eventsTable.tableView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(eventsTable.tableView)
        NSLayoutConstraint.activate([
            eventsTable.tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            eventsTable.tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            eventsTable.tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            eventsTable.tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        eventsTable.tableView.isHidden = true
        
        noEventsView.titleLabel.text = "No Upcomming Events"
        
        setupAccessibility()
        
        segmentChanged(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helpers
    @objc func updateUI() {
        // FIXME: can this be done better?
        getUser {
            self.getEvents {
                DispatchQueue.main.async {
                    self.eventsTable.tableView.reloadData()
                }
            }
        }
    }
    
    @objc private func clearData() {
        pastEvents = []
        upcommingEvents = []
        
        eventsTable.isDisplayingPast = false
        eventsTable.tableView.reloadData()
        
        segmentControl.selectedSegmentIndex = 0
        segmentChanged(self)
    }
    
    func setupAccessibility() {
        view.accessibilityIdentifier = "EventsVC"
        containerView.accessibilityIdentifier = "containerView"
        noEventsView.accessibilityIdentifier = "noEventsView"
        eventsTable.tableView.accessibilityIdentifier = "eventsTableView"
    }
    
    // MARK: - Actions
    @IBAction func showAccount(_ sender: Any) {
        guard let accountVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Account") as? UINavigationController else { return }
        
        accountVC.transitioningDelegate = self
        present(accountVC, animated: true, completion: nil)
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        if segmentControl.selectedSegmentIndex == 0 {
            noEventsView.titleLabel.text = "No Upcomming Events"
            noEventsView.isHidden = upcommingEvents.count > 0
            
            eventsTable.isDisplayingPast = false
            eventsTable.tableView.isHidden = upcommingEvents.count == 0
            eventsTable.tableView.reloadData()
        } else {
            noEventsView.titleLabel.text = "No Past Events"
            noEventsView.isHidden = pastEvents.count > 0
            
            eventsTable.isDisplayingPast = true
            eventsTable.tableView.isHidden = pastEvents.count == 0
            eventsTable.tableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    @IBAction func unwindFromCreateEvent(segue: UIStoryboardSegue) {
        if let createEventVC = segue.source as? CreateEventViewController, let event = createEventVC.event {
            upcommingEvents.append(event)
        }
        
        DispatchQueue.main.async {
            self.segmentChanged(self)
            self.eventsTable.tableView.reloadData()
        }
    }
    
    // MARK: - Networking
    func getEvents(completion: @escaping() -> Void) {

        EventsService().getAllEventsForCurrentUser { result in
            switch result {
            case .success(let events):
                self.parseResponse(events: events)
            case .failure(let error):
                print(error)
            }
            completion()
        }
    }
    
    func getUser(completion: @escaping () -> Void) {
        UserService().getCurrentUser { _ in
            completion()
        }
    }
    
    func parseResponse(events: [Event]) {
        
        for event in events {
            if event.date.isTodayOrFuture() {
                upcommingEvents.append(event)
            } else {
                pastEvents.append(event)
            }
        }
        
        DispatchQueue.main.async {
            self.eventsTable.tableView.reloadData()
            self.segmentChanged(self)
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension EventsViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let initialFrame = CGRect(x: self.view.frame.minX, y: self.view.frame.minY - self.view.frame.maxY, width: self.view.frame.width, height: self.view.frame.height)
        transition.originFrame = initialFrame
        transition.isPresenting = true
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        
        return transition
    }
}

// MARK: - EventsNavigationDelegate
extension EventsViewController: EventsNavigationDelegate {
    func didTap(event: Event) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let detailsViewController = storyBoard.instantiateViewController(withIdentifier: "EventDetailsViewController") as? EventDetailsViewController else { return }
        detailsViewController.event = event
        
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}
