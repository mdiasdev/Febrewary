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

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func showAccount(_ sender: Any) {
        guard let accountVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Account") as? UINavigationController else { return }
        
        accountVC.transitioningDelegate = self
        present(accountVC, animated: true, completion: nil)
    }
}

extension EventsViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let initialFrame = CGRect(x: self.view.frame.minX, y: self.view.frame.minY - self.view.frame.maxY, width: self.view.frame.width, height: self.view.frame.height)
        transition.originFrame = initialFrame
        transition.presenting = true
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        
        return transition
    }
}
