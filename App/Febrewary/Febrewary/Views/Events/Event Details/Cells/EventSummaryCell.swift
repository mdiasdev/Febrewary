//
//  EventSummaryCell.swift
//  Febrewary
//
//  Created by Matthew Dias on 9/8/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class EventSummaryCell: UITableViewCell {
    @IBOutlet weak var attendeeNameLabel: UILabel!
    @IBOutlet weak var roundLabel: UILabel!
    
    @IBOutlet weak var beerNameLabel: UILabel!
    @IBOutlet weak var brewerNameLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    func set(eventBeer: EventBeer) {
        attendeeNameLabel.text = eventBeer.attendee.name
        roundLabel.text = "(Round \(eventBeer.round))"
        
        beerNameLabel.text = eventBeer.beer.name
        brewerNameLabel.text = eventBeer.beer.brewerName
        
        scoreLabel.text = "\(eventBeer.score)"
    }
    
}
