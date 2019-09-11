//
//  EventsTableViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 6/16/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

protocol EventsNavigationDelegate: class {
    func didTap(event: Event)
}

class EventsTableViewController: UITableViewController {
    
    var isDisplayingPast = false
    var upcomingEvents = [Event]()
    var pastEvents = [Event]()
    
    weak var navigationDelegate: EventsNavigationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.register(SubtitleTableCell.self, forCellReuseIdentifier: "eventCell")
        tableView.backgroundColor = .clear
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isDisplayingPast ? pastEvents.count : upcomingEvents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        if isDisplayingPast {
            guard pastEvents.count > indexPath.row else { return UITableViewCell() }
        } else {
            guard upcomingEvents.count > indexPath.row else { return UITableViewCell() }
        }
        
        let event = isDisplayingPast ? pastEvents[indexPath.row] : upcomingEvents[indexPath.row]

        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.date.shortMonthDayYear

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var event: Event
        
        if isDisplayingPast {
            guard indexPath.row < pastEvents.count else { return }
            event = pastEvents[indexPath.row]
        } else {
            guard indexPath.row < upcomingEvents.count else { return }
            event = upcomingEvents[indexPath.row]
        }
        
        navigationDelegate?.didTap(event: event)
    }

}
