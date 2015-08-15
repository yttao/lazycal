//
//  LocationsSearchTableView.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/13/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import MapKit
import AddressBook
import AddressBookUI

class LocationsSearchTableView: SearchTableView {
    private var locationsTableViewController: LocationsTableViewController! {
        get {
            return selectedResultsTableViewController as! LocationsTableViewController
        }
        set {
            selectedResultsTableViewController = newValue
        }
    }
    
    private var filteredMapItems: [MapItem] {
        get {
            return searchResults as! [MapItem]
        }
        set {
            searchResults = newValue
        }
    }
    
    private var timer: NSTimer?
    // The current local search
    private var search: MKLocalSearch?
    
    // MARK: - Initializers
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeView("LocationCell")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeView("LocationCell")
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        initializeView("LocationCell")
    }
    
    /**
        Initializes the view.
    
        :param: reuseIdentifier The cell reuse identifier.
    */
    override func initializeView(reuseIdentifier: String) {
        filteredMapItems = [MapItem]()
        
        super.initializeView("LocationCell")
    }
    
    /**
        Loads initial data.
    
        :param: locationsTableViewController The `LocationsTableViewController` that contains this table view.
        :param: searchController The search controller.
    */
    override func loadData(#selectedResultsTableViewController: UITableViewController, searchController: SearchController) {
        self.locationsTableViewController = selectedResultsTableViewController as! LocationsTableViewController
        self.searchController = searchController
    }
    
    /**
        Filters the search results by the text entered in the search bar.
    
        **Note**: When using the iOS Simulator, it may fail to find search results and display the message "The network connection was lost." in the console. To fix this, restart the iOS Simulator.
    */
    override func filterSearchResults() {
        if searchText != nil && searchText != "" {
            // Create search request.
            let request = MKLocalSearchRequest()
            // Set text to search for.
            request.naturalLanguageQuery = searchText
            // Set location to begin searching from.
            request.region = locationsTableViewController.mapView!.region
            
            // Cancel old search requests.
            search?.cancel()
            
            // Start new search.
            search = MKLocalSearch(request: request)
            search?.startWithCompletionHandler() {
                (response: MKLocalSearchResponse!, error: NSError!) in
                if error != nil {
                    // Error warning
                    NSLog("Error occurred when searching: %@", error.localizedDescription)
                }
                else {
                    // Get MKMapItems that were found.
                    let mkMapItems = response.mapItems as! [MKMapItem]
                    // Convert to [MapItem]
                    let mapItems = mkMapItems.map({
                        return MapItem(coordinate: $0.placemark.coordinate, name: $0.name, addressDictionary: $0.placemark.addressDictionary)
                    })
                    // Show only MapItems that aren't already present in selected map items.
                    self.filteredMapItems = mapItems.filter({
                        !contains(self.locationsTableViewController.selectedMapItems, $0)
                    })
                }
                self.reloadData()
            }
        }
        else {
            filteredMapItems.removeAll(keepCapacity: false)
            reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension LocationsSearchTableView: UITableViewDelegate {
    // MARK: - Methods related to selecting cells.
    
    /**
        Selection will append to selected locations and clear the search bar.
    
        The filter ensures that search results will not show locations that are already selected, so this method cannot add duplicate locations.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mapItem = filteredMapItems[indexPath.row]
        locationsTableViewController.addNewMapItem(mapItem)
        searchController!.searchBar.text = nil
    }
}

// MARK: - UITableViewDataSource
extension LocationsSearchTableView: UITableViewDataSource {
    // MARK: - Methods for setting up cell content.
    
    /**
        Creates a cell with map item name and address.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! SearchTableViewCell
        
        let mapItem = filteredMapItems[indexPath.row]
        let name = mapItem.name
        let address = mapItem.address
        cell.mainLabel.text = name
        cell.subLabel.text = address
        boldSearchTextInLabel(cell.mainLabel)
        
        return cell
    }
}

// MARK: - UISearchResultsUpdating
extension LocationsSearchTableView: UISearchResultsUpdating {
    /**
        When the search bar is activated or the text in the search bar changes, start updating search results.
    
        Search results are controlled by an NSTimer. Whenever this function is called, the last timer used is invalidated in order to prevent sending previous search requests when the text to search has changed. Then, it begins a new timer that waits 0.3 seconds before starting a search request.
    */
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Destroy last request and make a new one
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "filterSearchResults", userInfo: searchController.searchBar.text, repeats: false)
        reloadData()
    }
}
