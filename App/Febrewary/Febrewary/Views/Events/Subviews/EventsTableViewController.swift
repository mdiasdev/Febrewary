//
//  EventsTableViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 6/16/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {
    
    var isDisplayingPast = false
    var upcommingEvents = [Event]()
    var pastEvents = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.register(SubtitleTableCell.self, forCellReuseIdentifier: "eventCell")
        tableView.backgroundColor = .clear
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isDisplayingPast ? pastEvents.count : upcommingEvents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        if isDisplayingPast {
            guard pastEvents.count > indexPath.row else { return UITableViewCell() }
        } else {
            guard upcommingEvents.count > indexPath.row else { return UITableViewCell() }
        }
        
        let event = isDisplayingPast ? pastEvents[indexPath.row] : upcommingEvents[indexPath.row]

        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.date.shortMonthDayYear

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}