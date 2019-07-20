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
        fetchBeersForCurrentUser()
        
        self.searchBar.isHidden = true
    }
    
    func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UINib(nibName: "BeerTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "beerCell")
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
    
    func updateDataSource() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.beers = myBeers
        case 1:
            self.beers = searchedBeers
        default:
            assertionFailure("unexpected segment tapped")
        }
        
        tableView.reloadData()
    }
    
    func fetchBeersForCurrentUser() {
        BeerService().getBeersForCurrentUser { (result) in
            switch result {
            case .success(let beers):
                self.myBeers = beers
                DispatchQueue.main.async {
                    self.segmentDidChange(self)
                }
            case .failure:
                print("failed to get beers for current user")
            }
        }
    }
    
    @IBAction func segmentDidChange(_ sender: Any) {
        DispatchQueue.main.async {
            self.showOrHideSearchBar()
            self.updateDataSource()
        }
    }
    
    @IBAction func unwindFromAddBeer(segue: UIStoryboardSegue) {
        
        if let addBeerVC = segue.source as? AddBeerViewController, let beer = addBeerVC.beer {
            myBeers.append(beer)
        }
        
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentDidChange(self)
    }
}

extension BeerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: go to beer details
    }
}

extension BeerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "beerCell", for: indexPath) as? BeerTableViewCell,
            beers.count > indexPath.row else {
            return UITableViewCell()
        }
        
        let beer = beers[indexPath.row]
        
        cell.titleLabel?.text = beer.name
        cell.subTitleLabel?.text = beer.brewerName
        
        return cell
    }
    
    
}
