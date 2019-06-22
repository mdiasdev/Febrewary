//
//  SubtitleTableCell.swift
//  Febrewary
//
//  Created by Matthew Dias on 6/16/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class SubtitleTableCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
