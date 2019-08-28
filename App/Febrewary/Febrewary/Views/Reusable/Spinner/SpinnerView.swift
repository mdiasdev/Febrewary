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
    func showSpinner(with title: String) {
        spinnerView.spinner.startAnimating()
        self.view.addSubview(spinnerView)
        
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinnerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            spinnerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            spinnerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            spinnerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
        spinnerView.titleLabel.text = title
    }
    
    func hideSpinner() {
        DispatchQueue.main.async { [weak self] in
            self?.spinnerView.spinner.stopAnimating()
            self?.spinnerView.removeFromSuperview()
        }
    }
}

class SpinnerView: UIView {
    @IBOutlet fileprivate weak var spinner: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
