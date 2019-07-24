//
//  BeerDetailsViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 7/23/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class BeerDetailsViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var brewerLabel: UILabel!
    @IBOutlet weak var abvLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    var beer: Beer!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setLabels()
    }
    
    func setLabels() {
        nameLabel.text = beer.name
        brewerLabel.text = beer.brewerName
        abvLabel.text = "\(beer.abv) %"
        averageLabel.text = String(format: "%.2f", beer.averageScore)
        totalLabel.text = "\(beer.totalScore)"
    }

}
