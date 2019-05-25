//
//  TopDownAnimator.swift
//  Febrewary
//
//  Created by Matthew Dias on 5/25/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation
import UIKit

class TopDownAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.3
    var presenting = true
    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { return duration }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        containerView.addSubview(toView)
        let accountVC = presenting ? toView : transitionContext.view(forKey: .from)!
        
        let initialFrame = presenting ? originFrame : accountVC.frame
        let finalFrame = presenting ? accountVC.frame : originFrame

        accountVC.frame = initialFrame
        UIView.animate(withDuration: duration, animations: {
            accountVC.frame = finalFrame
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}
