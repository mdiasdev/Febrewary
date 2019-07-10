//
//  EventDetailsTableViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 7/9/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class EventDetailsTableViewController: UITableViewController {
    
    var event: Event!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTable()
    }
    
    func setupTable() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "attendeeCell")
        tableView.register(UINib(nibName: "EventDateAddressTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "dateAndAddressCell")
        
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return event.attendees.count
        default:
            assertionFailure("Table only supports 2 sections")
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "dateAndAddressCell", for: indexPath) as? EventDateAddressTableViewCell else {
                return UITableViewCell()
            }
            
            cell.dateLabel.text = event.date.shortMonthDayYearWithTime
            cell.addressLabel.text = event.address
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "attendeeCell", for: indexPath)
            
            cell.textLabel?.text = "\(event.attendees[indexPath.row].firstName) \(event.attendees[indexPath.row].lastName)"
            
            return cell
        default:
            assertionFailure("Table only supports 2 sections")
            return UITableViewCell()
        }

    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Attendees"
        }
        
        return nil
    }
}
