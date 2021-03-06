//
//  LocationTimeZoneTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 9/1/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class LocationTimeZoneTableViewController: UITableViewController {
    var delegate: LocationTimeZoneTableViewControllerDelegate?
    
    private var results = [NSTimeZone]()
    
    private static var timeZones: [NSTimeZone] = {
        let timeZoneNames = NSTimeZone.knownTimeZoneNames() as! [String]
        
        let timeZones = timeZoneNames.map({
            return NSTimeZone(name: $0)!
        })
        return timeZones
    }()
    
    private let reuseIdentifier = "LocationTimeZoneCell"
    
    private var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    
        initializeSearchController()
    }
    
    /**
        Initializes the search controller with the search bar at the top of the screen.
    */
    private func initializeSearchController() {
        // Create search controller.
        searchController = {
            let controller = UISearchController(searchResultsController: nil)
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            
            controller.searchBar.searchBarStyle = .Default
            controller.searchBar.placeholder = "Search for Locations"
            controller.searchBar.sizeToFit()
            controller.searchResultsUpdater = self
            
            self.tableView.tableHeaderView = controller.searchBar

            return controller
            }()
        
        
        
        // Hides search controller on segue.
        definesPresentationContext = true
    }
    
    /**
        Updates the search results by the search text.
    */
    func updateResults() {
        let searchText = searchController.searchBar.text
        
        results = LocationTimeZoneTableViewController.timeZones.filter({
            let containsMatch = $0.nameString().rangeOfString(searchText, options: .CaseInsensitiveSearch)
            return containsMatch != nil
        })
    }
}

// MARK: - UITableViewDelegate
extension LocationTimeZoneTableViewController: UITableViewDelegate {
    /**
        The number of rows equals the number of time zone search results.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    /**
        On selection, inform the delegate of the selected time zone and return.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let timeZone = results[indexPath.row]
        delegate?.locationTimeZoneTableViewControllerDidUpdateTimeZone(timeZone)
        navigationController!.popViewControllerAnimated(true)
    }
}

extension LocationTimeZoneTableViewController: UITableViewDataSource {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! UITableViewCell
        
        let timeZone = results[indexPath.row]
        cell.textLabel?.text = timeZone.nameString()
        
        return cell
    }
}

// MARK: - UISearchResultsUpdating
extension LocationTimeZoneTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        updateResults()
        tableView.reloadData()
    }
}

protocol LocationTimeZoneTableViewControllerDelegate {
    func locationTimeZoneTableViewControllerDidUpdateTimeZone(timeZone: NSTimeZone)
}