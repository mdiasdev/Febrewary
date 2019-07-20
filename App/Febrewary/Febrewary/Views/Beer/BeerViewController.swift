//
//  BeerViewController.swift
//  Febrewary
//
//  Created by Matthew Dias on 7/20/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import UIKit

class BeerViewController: UIViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showOrHideSearchBar()
    }
    
    func showOrHideSearchBar() {
        UIView.animate(withDuration: 0.25) {
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.searchBar.alpha = 0
                self.searchBar.isHidden = true
            } else {
                self.searchBar.alpha = 100
                self.searchBar.isHidden = false
            }
        }
    }
    
    @IBAction func segmentDidChange(_ sender: Any) {
        DispatchQueue.main.async {
            self.showOrHideSearchBar()
        }
    }
    
    @IBAction func tappedAdd(_ sender: Any) {
    }
}
