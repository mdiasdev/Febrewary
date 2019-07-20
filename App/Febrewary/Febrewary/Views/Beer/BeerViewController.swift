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
    
    var beers = [Beer]()
    
    private var myBeers = [Beer]()
    private var searchedBeers = [Beer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTable()
        
        self.searchBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.segmentDidChange(self)
        }
    }
    
    func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "beerCell")
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
        self.showOrHideSearchBar()
        
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            self.beers = self.myBeers
        case 1:
            self.beers = self.searchedBeers
        default:
            assertionFailure("unexpected segment tapped")
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func unwindFromAddBeer(segue: UIStoryboardSegue) {
        
        if let addBeerVC = segue.source as? AddBeerViewController, let beer = addBeerVC.beer {
            myBeers.append(beer)
        }
        
        DispatchQueue.main.async {
            self.segmentedControl.selectedSegmentIndex = 0
            self.segmentDidChange(self)
        }
    }
}

extension BeerViewController: UITableViewDelegate {
    
}

extension BeerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "beerCell"),
            beers.count > indexPath.row else {
            return UITableViewCell()
        }
        
        let beer = beers[indexPath.row]
        
        cell.textLabel?.text = beer.name
        cell.detailTextLabel?.text = beer.brewerName
        
        return cell
    }
    
    
}
