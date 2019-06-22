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
    
    private var upcommingEvents = [Event]()
    private var pastEvents = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        noEventsView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(noEventsView)
        NSLayoutConstraint.activate([
            noEventsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            noEventsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            noEventsView.topAnchor.constraint(equalTo: containerView.topAnchor),
            noEventsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
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
    }
    
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
    
    func getEvents() {
        let url = URLBuilder(endpoint: .eventsForCurrentUser).buildUrl()
        
        ServiceClient().get(url: url) { [weak self] result in
            switch result {
            case .success(let json):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                      let events = try? decoder.decode([Event].self, from: data) else {
                        print("bad data")
                        return
                }
                self?.parseResponse(events: events)

            case .failure(let error):
                print(error)
            }
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
        
        eventsTable.upcommingEvents = upcommingEvents
        eventsTable.pastEvents = pastEvents
        
        DispatchQueue.main.async {
            self.eventsTable.tableView.reloadData()
            self.segmentChanged(self.segmentControl)
        }
    }
}

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
