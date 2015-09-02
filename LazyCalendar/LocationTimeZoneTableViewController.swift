//
//  LocationTimeZoneTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 9/1/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class LocationTimeZoneTableViewController: UITableViewController {
    private var results = [String]()
    
    private static let timeZones = NSTimeZone.knownTimeZoneNames() as! [String]
    
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
            let containsMatch = $0.rangeOfString(searchText, options: .CaseInsensitiveSearch)
            return containsMatch != nil
        })
    }
    
    /**
        Converts a raw time zone name into a readable string.
    
        :param: timeZoneName The time zone name.
        :returns: A readable string for the time zone name.
    */
    func timeZoneNameToReadableString(timeZoneName: String) -> String {
        // Remove underscores
        let timeZoneNameNoUnderscores = timeZoneName.stringByReplacingOccurrencesOfString("_", withString: " ")
        
        // Delimit string by "/"
        let timeZoneNameArray = timeZoneNameNoUnderscores.componentsSeparatedByString("/")
        // Reverse order of time zone name components (so it goes from most specific location name to most general location name)
        let reversedTimeZoneNameArray = timeZoneNameArray.reverse()
        
        // Separate components of the time zone name by commas.
        return ", ".join(reversedTimeZoneNameArray)
    }
}

// MARK: - UITableViewDelegate
extension LocationTimeZoneTableViewController: UITableViewDelegate {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
}

extension LocationTimeZoneTableViewController: UITableViewDataSource {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! UITableViewCell
        
        cell.textLabel?.text = timeZoneNameToReadableString(results[indexPath.row])
        
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
