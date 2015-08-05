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
    
    private let reuseIdentifier = "LocationCell"
    
    private var timer: NSTimer?
    
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
        Loads initial selected locations.
    
        :param: locations The initial selected locations.
    */
    func loadData(locations: [MKMapItem]) {
        self.selectedLocations = locations
    }
    
    /**
        Sets the map view.
    
        :param: mapView The map view used by the locations view controller.
    */
    func setMapView(mapView: MKMapView?) {
        self.mapView = mapView
    }
    
    /**
        Filters the search results by the text entered in the search bar.
    
        :param: timer The timer controlling when the search request fires.
    */
    func filterLocations(timer: NSTimer) {
        let searchText = timer.userInfo as? String
        
        // Create search request if search isn't empty
        if searchText != "" {
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = searchText
            // Set location to begin searching from
            request.region = mapView!.region
            
            // Search for string
            let search = MKLocalSearch(request: request)
            search.startWithCompletionHandler({(response: MKLocalSearchResponse!,
                error: NSError!) in
                if error != nil {
                    NSLog("Error occurred when searching: %@", error.localizedDescription)
                }
                else {
                    for item in response.mapItems as! [MKMapItem] {
                        println(item.name)
                    }
                    self.filteredLocations = response.mapItems as! [MKMapItem]
                }
                println(self.filteredLocations.count)
                self.tableView.reloadData()
            })
        }
        else {
            filteredLocations.removeAll(keepCapacity: false)
            println(filteredLocations.count)
            tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension LocationsTableViewController: UITableViewDelegate {
    /**
        Prevents indenting for showing circular edit button on the left when editing.
    */
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    /**
        Gives option to delete contact.
    */
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    /**
        If searching, selection will append to selected locations and clear the search bar.
    
        TODO: The filter ensures that search results will not show contacts that are already selected, so this method cannot add duplicate contacts.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchController != nil && searchController!.active && filteredLocations.count > 0 {
            selectedLocations.append(filteredLocations[indexPath.row])
            searchController?.searchBar.text = nil
        }
    }
}

// MARK: - UITableViewDataSource
extension LocationsTableViewController: UITableViewDataSource {
    /**
        There is 1 section in the table.
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
        If searching, the number of rows is the number of search results. If not searching, the number of rows is the number of selected locations.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController != nil && searchController!.active && filteredLocations.count > 0 {
            return filteredLocations.count
        }
        return selectedLocations.count
    }
    
    /**
        Allow table cells to be deleted.
    
        Note: If tableView.editing = true, the left circular edit option will appear. If contacts are being searched, the table cannot be edited.
    */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if searchController != nil && searchController!.active && filteredLocations.count > 0 {
            return false
        }
        return true
    }
    
    /**
        Display cell with name as text label and phone number as detail text label. If searching, show a LocationCell for the filtered location. If not searching, show a LocationCell for the selected location.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! UITableViewCell
        
        if searchController != nil && searchController!.active && filteredLocations.count > 0 {
            let location = filteredLocations[indexPath.row]
            if let name = location.name {
                cell.textLabel?.text = name
            }
            else {
                cell.textLabel?.text = nil
            }
            if let phoneNumber = location.phoneNumber {
                cell.detailTextLabel?.text = filteredLocations[indexPath.row].phoneNumber
            }
            else {
                cell.detailTextLabel?.text = nil
            }
        }
        else {
            let location = selectedLocations[indexPath.row]
            if let name = location.name {
                cell.textLabel?.text = selectedLocations[indexPath.row].name
            }
            else {
                cell.textLabel?.text = nil
            }
            if let phoneNumber = location.phoneNumber {
                cell.detailTextLabel?.text = selectedLocations[indexPath.row].phoneNumber
            }
            else {
                cell.detailTextLabel?.text = nil
            }
        }
        
        return cell
    }
}

// MARK: - UISearchResultsUpdating
extension LocationsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "filterLocations:", userInfo: searchController.searchBar.text, repeats: false)
    }
}