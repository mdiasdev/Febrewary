//
//  SpinnerView.swift
//  Febrewary
//
//  Created by Matthew Dias on 8/27/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

protocol Spinable: UIViewController {
    var spinnerView: SpinnerView { get }
}

extension Spinable {
    // MARK: - Presentation
    func show() {
        spinnerView.spinner.startAnimating()
        self.view.addSubview(spinnerView)
        
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinnerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            spinnerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            spinnerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            spinnerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }
    
    func hide() {
        spinnerView.spinner.stopAnimating()
        spinnerView.removeFromSuperview()
    }
}

class SpinnerView: UIView {
    @IBOutlet fileprivate weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    init(title: String) {
        super.init(frame: CGRect.zero)
        
        titleLabel.text = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
