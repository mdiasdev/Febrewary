//
//  EventDetailsViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 7/13/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapsButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var buttonContainerHeightConstraint: NSLayoutConstraint!
    
    var event: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if event.isOver {
            mapsButton.isHidden = true
            navigationItem.rightBarButtonItem = nil
        } else {
            let addBarButton = UIBarButtonItem(image: UIImage(named: "Plus_ico"), style: .plain, target: self, action: #selector(addTapped))
            self.navigationItem.setRightBarButtonItems([addBarButton], animated: false)
        }
        
        if let user = User().retrieve(), event.hasStarted && !event.isOver {
            if user.id == event.pourerId {
                performSegue(withIdentifier: "Pouring", sender: self)
            } else {
                performSegue(withIdentifier: "Voting", sender: self)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTable()
        dateLabel.text = event.date.shortMonthDayYearWithTime
        addressLabel.text = event.address
        startButton.layer.cornerRadius = 8
        
        if let user = User().retrieve(), user.id != event.pourerId {
            buttonContainerHeightConstraint.constant = 0
            startButton.isHidden = true
        }
        
        startButton.isEnabled = event.date.isToday()
    }
    
    func setupTable() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "attendeeCell")

        tableView.tableFooterView = UIView()
    }

    // MARK: - Actions
    @objc func addTapped() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Attendee", style: .default, handler: { _ in self.addAttendeeTapped() }))
        actionSheet.addAction(UIAlertAction(title: "Beer", style: .default, handler: { _ in self.addBeerTapped() }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func addAttendeeTapped() {
        performSegue(withIdentifier: "addAttendee", sender: self)
    }
    
    func addBeerTapped() {
        let alert = UIAlertController(title: "unimplemented", message: "this is a future feature", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addAttendeeVC = segue.destination as? AddAttendeeViewController {
            addAttendeeVC.event = event
        } else if let pouringScreen = segue.destination as? PouringViewController {
            pouringScreen.event = event
        } else if let votingScreen = segue.destination as? VoteViewController {
            votingScreen.event = event
        }
    }
}

extension EventDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return !event.isOver ? "Attendees" : nil
    }
    
}

extension EventDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event.attendees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if event.isOver {
            return UITableViewCell() // full detail cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "attendeeCell", for: indexPath)
            
            cell.textLabel?.text = event.attendees[indexPath.row].name
            
            return cell
        }
    }
    
    
}
