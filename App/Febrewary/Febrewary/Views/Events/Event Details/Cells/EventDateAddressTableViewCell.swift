//
//  EventDateAddressTableViewCell.swift
//  Febrewary
//
//  Created by Matthew Dias on 7/9/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class EventDateAddressTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func openInMaps(_ sender: Any) {
    }
    
}
