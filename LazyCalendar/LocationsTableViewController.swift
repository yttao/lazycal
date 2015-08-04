//
//  LocationsTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/3/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import MapKit
import AddressBook
import CoreLocation

class LocationsTableViewController: UITableViewController {
    private var searchController: UISearchController?
    
    private var selectedLocations: [MKMapItem]!
    private var filteredLocations = [MKMapItem]()
    
    private var mapView: MKMapView?
    
    /**
        Sets the map view.
    
        :param: mapView The map view used by the locations view controller.
    */
    func setMapView(mapView: MKMapView?) {
        self.mapView = mapView
    }
    
    /**
        Sets table view delegate and data source and creates search controller.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if selectedLocations == nil {
            selectedLocations = [MKMapItem]()
        }
        
        initializeSearchController()
        definesPresentationContext = true
    }
    
    /**
        Initializes the search controller.
    */
    func initializeSearchController() {
        searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Search for Locations"
            controller.hidesNavigationBarDuringPresentation = false
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
    }
    
    /**
        Filters the search results by the text entered in the search bar.
    
        :param: searchText The text to filter the results.
    */
    func filterLocationsForSearchText(searchText: String) {
        // Create search request
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        // Set location to begin searching from
        request.region = mapView!.region
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({(response: MKLocalSearchResponse!,
            error: NSError!) in
            
            if error != nil {
                NSLog("Error occurred when searching locations: %@", error.localizedDescription)
            }
            else if response.mapItems.count == 0 {
                NSLog("No matches found")
            }
            else {
                NSLog("Matches found: %d", response.mapItems.count)
                
                for item in response.mapItems as! [MKMapItem] {
                    println("Name = \(item.name)")
                    println("Phone = \(item.phoneNumber)")
                }
            }
        })
    }
}

// MARK: - UITableViewDelegate
extension LocationsTableViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension LocationsTableViewController: UITableViewDataSource {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as! UITableViewCell
        
        return cell
    }
}

// MARK: - UISearchResultsUpdating
extension LocationsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterLocationsForSearchText(searchController.searchBar.text)
        tableView.reloadData()
    }
}