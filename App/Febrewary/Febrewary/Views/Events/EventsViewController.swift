//
//  EventsViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/18/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController {
    var transition = TopDownAnimator()
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!

    let noEventsView = Bundle.main.loadNibNamed("NoEventsView", owner: self, options: nil)?.first as! NoEventsView // FIXME: no force unwrapping
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        } else {
            noEventsView.titleLabel.text = "No Past Events"
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
