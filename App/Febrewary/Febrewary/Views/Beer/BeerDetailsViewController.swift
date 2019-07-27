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
    @IBOutlet weak var addButton: UIButton!
    
    var beer: Beer!
    var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        events = (events as NSArray).retrieve() as? [Event] ?? []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addButton.layer.cornerRadius = 8
        
        setLabels()
    }
    
    func setLabels() {
        nameLabel.text = beer.name
        brewerLabel.text = beer.brewerName
        abvLabel.text = "\(beer.abv) %"
        averageLabel.text = String(format: "%.2f", beer.averageScore)
        totalLabel.text = "\(beer.totalScore)"
    }
    
    func addTo(event: Event) {
        EventsService().addBeer(beer.id, to: event) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.showSuccess(for: event)
                case .failure(let error):
                    self.show(error: error)
                }
            }
        }
    }
    
    func showSuccess(for event: Event) {
        let alert = UIAlertController(title: "Success", message: "\(beer.name) successfully added to \(event.name)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func show(error: Error) {
        // TODO: better error handling
    }

    @IBAction func addToEventTapped(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        for event in events {
            actionSheet.addAction(UIAlertAction(title: event.name, style: .default, handler: { _ in
                self.addTo(event: event)
            }))
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
}
