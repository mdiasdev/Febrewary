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
    var isPresenting = true
    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { return duration }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        var accountVC: UIView
        
        if isPresenting {
            let toView = transitionContext.view(forKey: .to)!
            containerView.addSubview(toView)
            accountVC = toView
        } else {
            accountVC = transitionContext.view(forKey: .from)!
        }
        
        let initialFrame = isPresenting ? originFrame : accountVC.frame
        let finalFrame = isPresenting ? accountVC.frame : originFrame

        accountVC.frame = initialFrame
        UIView.animate(withDuration: duration, animations: {
            accountVC.frame = finalFrame
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}
