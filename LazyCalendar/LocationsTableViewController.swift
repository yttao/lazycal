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
import AddressBookUI
import CoreLocation

class LocationsTableViewController: UITableViewController {
    private var searchController: UISearchController?
    
    private var selectedLocations: [MKMapItem]!
    private var filteredLocations = [MKMapItem]()
    
    private weak var mapView: MKMapView?
    
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
                    let mapItems = response.mapItems as! [MKMapItem]
                    // Remove all search results that already exist in selectedLocations
                    self.filteredLocations = mapItems.filter({
                        !contains(self.selectedLocations, $0)
                    })
                }
                self.tableView.reloadData()
            })
        }
        else {
            filteredLocations.removeAll(keepCapacity: false)
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
        If searching, selection will append to selected locations and clear the search bar. If not searching, selection will center the map on the selected location.
    
        TODO: The filter ensures that search results will not show contacts that are already selected, so this method cannot add duplicate contacts.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchController != nil && searchController!.active && searchController!.searchBar.text != "" {
            let mapItem = filteredLocations[indexPath.row]
            selectedLocations.append(mapItem)
            addMapItemToMapView(mapItem)
            searchController?.searchBar.text = nil
        }
        else {
            let mapItem = selectedLocations[indexPath.row]
            NSNotificationCenter.defaultCenter().postNotificationName("LocationChanged", object: self, userInfo: ["Location": mapItem.placemark.location])
        }
    }
    
    /**
        Shows an annotation at the map item's location with displayed information about the map item.
    
        :param: mapItem The map item to show on the map view.
    */
    func addMapItemToMapView(mapItem: MKMapItem) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapItem.placemark.coordinate
        annotation.title = mapItem.name
        
        //let address = ABCreateStringWithAddressDictionary(mapItem.placemark.addressDictionary, false)
        let address = stringFromAddressDictionary(mapItem.placemark.addressDictionary)
        annotation.subtitle = address
        println(address)
        
        mapView?.addAnnotation(annotation)
    }
    
    /**
        Makes an address string out of the available information in the address dictionary.
    
        :param: addressDictionary A dictionary of address information.
    */
    func stringFromAddressDictionary(addressDictionary: [NSObject: AnyObject]) -> String {
        if var lines = addressDictionary["FormattedAddressLines"] as? [String] {
            // Don't include country in address
            if let countryIndex = find(lines, addressDictionary[kABPersonAddressCountryKey] as! String) {
                lines.removeAtIndex(countryIndex)
            }
            
            // Format address if it has a specific street address
            if addressDictionary[kABPersonAddressStreetKey] as? String != nil && contains(lines, addressDictionary[kABPersonAddressStreetKey] as! String) {
                var address = ""
                for i in 0..<lines.count {
                    address += lines[i]
                    if i == 0 {
                        address += ", "
                    }
                    else if i != lines.count - 1 {
                        address += " "
                    }
                }
                return address
            }
            // Format address if it doesn't have a specific street address
            else {
                return join(" ", lines)
            }
        }
        else {
            return ABCreateStringWithAddressDictionary(addressDictionary, false)
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
        if searchController != nil && searchController!.active && searchController!.searchBar.text != "" {
            return filteredLocations.count
        }
        return selectedLocations.count
    }
    
    /**
        Allow table cells to be deleted.
    
        Note: If tableView.editing = true, the left circular edit option will appear. If contacts are being searched, the table cannot be edited.
    */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if searchController != nil && searchController!.active && searchController!.searchBar.text != "" {
            return false
        }
        return true
    }
    
    /**
        Selected locations can be removed by swiping left and pressing delete.
    */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            selectedLocations.removeAtIndex(indexPath.row)
            tableView.endUpdates()
        }
    }
    
    /**
        Display cell with name as text label and phone number as detail text label. If searching, show a LocationCell for the filtered location. If not searching, show a LocationCell for the selected location.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! UITableViewCell
        
        if searchController != nil && searchController!.active && searchController!.searchBar.text != "" {
            let mapItem = filteredLocations[indexPath.row]
            let name = mapItem.name
            let address = stringFromAddressDictionary(mapItem.placemark.addressDictionary)
            cell.textLabel?.text = mapItem.name
            cell.detailTextLabel?.text = address
        }
        else {
            let mapItem = selectedLocations[indexPath.row]
            let name = mapItem.name
            let address = stringFromAddressDictionary(mapItem.placemark.addressDictionary)
            cell.textLabel?.text = name
            cell.detailTextLabel?.text = address
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