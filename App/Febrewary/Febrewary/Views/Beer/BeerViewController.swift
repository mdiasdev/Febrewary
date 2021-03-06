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
    var selectedBeer: Beer?
    
    private var myBeers = [Beer]()
    private var searchedBeers = [Beer]()
    
    var searchTimer: Timer?
    var searchText: String?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action:#selector(refreshTable),
                                 for: UIControl.Event.valueChanged)
        
        return refreshControl
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTable()
        fetchBeersForCurrentUser {
            DispatchQueue.main.async {
                self.updateDataSource()
            }
        }
        
        searchBar.delegate = self
        
        tableView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: .loggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearData), name: .loggedOut, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
        
        tableView.register(UINib(nibName: "BeerTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "beerCell")
    }
    
    @objc func refreshTable() {
        fetchBeersForCurrentUser {
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.updateDataSource()
            }
        }
        
    }
    
    func showOrHideSearchBar() {
        UIView.animate(withDuration: 0.25) {
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.searchBar.alpha = 100
                self.searchBar.isHidden = false
            } else {
                self.searchBar.alpha = 0
                self.searchBar.isHidden = true
            }
        }
    }
    
    func updateDataSource() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.beers = searchedBeers
        case 1:
            self.beers = myBeers
        default:
            assertionFailure("unexpected segment tapped")
        }
        
        if beers.count == 0  {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            tableView.reloadData()
        }
        
        showOrHideSearchBar()
    }
    
    @objc private func clearData() {
        self.beers = []
        tableView.reloadData()
        
        segmentedControl.selectedSegmentIndex = 0
        segmentDidChange(self)
    }
    
    // MARK: - Networking
    func fetchBeersForCurrentUser(completion: @escaping () -> Void) {
        BeerService().getBeersForCurrentUser { result in
            switch result {
            case .success(let beers):
                self.myBeers = beers
            case .failure:
                print("failed to get beers for current user")
            }
            
            completion()
        }
    }
    
    @objc func search() {
        guard let searchText = searchBar.text else { return }
        
        self.searchText = searchText
        
        BeerService().search(for: searchText) { result in
            switch result {
            case .success(let beers):
                self.searchedBeers = beers
                DispatchQueue.main.async {
                    self.updateDataSource()
                    self.showOrHideSearchBar()
                }
            case .failure:
                print("failed to get beers for current user")
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func segmentDidChange(_ sender: Any) {
        DispatchQueue.main.async {
            self.updateDataSource()
        }
    }
    
    // MARK: - Navigation
    @IBAction func unwindFromAddBeer(segue: UIStoryboardSegue) {
        
        if let addBeerVC = segue.source as? AddBeerViewController, let beer = addBeerVC.beer {
            myBeers.append(beer)
        }
        
        self.segmentedControl.selectedSegmentIndex = 1
        self.segmentDidChange(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            selectedBeer = nil
            if let selectedRow = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedRow, animated: false)
            }
        }
        
        guard let beerDetails = segue.destination as? BeerDetailsViewController, selectedBeer != nil else { return }
        
        beerDetails.beer = selectedBeer
    }
}

// MARK: - UITableViewDelegate
extension BeerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard beers.count > indexPath.row else { return }
        
        selectedBeer = beers[indexPath.row]
        
        performSegue(withIdentifier: "beerDetails", sender: self)
    }
}

// MARK: - UITableViewDataSource
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
        
        if let searchText = searchText {
            let attributedTitle = NSMutableAttributedString(string: beer.name)
            let attributedSubtitle = NSMutableAttributedString(string: beer.brewerName)
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            
            attributedTitle.addAttributes(underlineAttribute, range: (beer.name as NSString).range(of: searchText))
            attributedSubtitle.addAttributes(underlineAttribute, range: (beer.brewerName as NSString).range(of: searchText))
            
            cell.titleLabel.attributedText = attributedTitle
            cell.subTitleLabel.attributedText = attributedSubtitle
        } else {
            cell.titleLabel?.text = beer.name
            cell.subTitleLabel?.text = beer.brewerName
        }
        
        return cell
    }  
}

// MARK: - UISearchBarDelegate
extension BeerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(search), userInfo: nil, repeats: false)
    }
}
