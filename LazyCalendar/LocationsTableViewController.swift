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
    private var searchEnabled = true

    private var annotations: [MKPointAnnotation]!
    private var selectedLocations: [MKMapItem]!
    private var filteredLocations = [MKMapItem]()
    
    private weak var mapView: MKMapView?
    
    private let reuseIdentifier = "LocationCell"
    
    private var timer: NSTimer?
    
    // MARK: - Methods for setting up view controller and data.
    
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
        if annotations == nil {
            annotations = [MKPointAnnotation]()
        }
        
        initializeSearchController()
        definesPresentationContext = true
    }
    
    /**
        Initializes the search controller.
    */
    private func initializeSearchController() {
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
        
        // Convert map items to annotations
        annotations = selectedLocations.map({
            mapItem in
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapItem.placemark.coordinate
            annotation.title = mapItem.name
            let address = self.stringFromAddressDictionary(mapItem.placemark.addressDictionary)
            annotation.subtitle = address
            return annotation
        })
        
        // Add all annotations to map view.
        mapView?.addAnnotations(annotations)
    }
    
    /**
        Sets the map view.
    
        :param: mapView The map view used by the locations view controller.
    */
    func setMapView(mapView: MKMapView?) {
        self.mapView = mapView
    }
    
    // MARK: - Methods related to searching.
    
    /**
        Returns `true` if the user is currently searching for a location; `false` otherwise.
    
        :returns: `true` if the user is currently searching; `false` otherwise.
    */
    private func searching() -> Bool {
        return searchController != nil && searchController!.active && searchController!.searchBar.text != ""
    }
    
    /**
        Filters the search results by the text entered in the search bar.
    
        :param: timer The timer controlling when the search request fires.
    */
    func filterLocations(timer: NSTimer) {
        let searchText = timer.userInfo as? String
        
        // Create search request if search isn't empty
        if searching() {
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = searchText
            // Set location to begin searching from
            request.region = mapView!.region
            
            // Search for string
            let search = MKLocalSearch(request: request)
            search.startWithCompletionHandler() {
                (response: MKLocalSearchResponse!, error: NSError!) in
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
            }
        }
        else {
            filteredLocations.removeAll(keepCapacity: false)
            tableView.reloadData()
        }
    }
    
    // MARK: - Methods for adding map items.
    
    /**
        Adds a new map item.
    
        The new map item annotation is added to the map view and the map item is appended to the table view.
    */
    private func addNewMapItem(mapItem: MKMapItem) {
        addMapItemToMapView(mapItem)
        selectedLocations.append(mapItem)
        searchController?.searchBar.text = nil
    }
    
    /**
        Shows an annotation at the map item's location with displayed information about the map item.
    
        :param: mapItem The map item to show on the map view.
    */
    private func addMapItemToMapView(mapItem: MKMapItem) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapItem.placemark.coordinate
        annotation.title = mapItem.name
        
        let address = stringFromAddressDictionary(mapItem.placemark.addressDictionary)
        annotation.subtitle = address
        
        mapView?.addAnnotation(annotation)
        annotations.append(annotation)
    }
    
    // MARK: - Methods for removing map items.
    
    /**
        Deletes a selected map item.
    
        The map item annotation is removed from the map view and the map item is removed from the table view.
    
        :param: mapItem The map item to delete.
        :param: indexPath The index path of the deleted map item.
    */
    private func deleteSelectedMapItem(mapItem: MKMapItem, atIndexPath indexPath: NSIndexPath) {
        removeMapItemFromMapView(mapItem)
        removeMapItemFromTableView(indexPath)
    }
    
    /**
        Removes the annotation at the map item's location.
    
        :param: mapItem The map item to remove from the map view.
    */
    private func removeMapItemFromMapView(mapItem: MKMapItem) {
        let annotation = annotations.filter({
            let nameMatch = $0.title == mapItem.name
            let addressMatch = $0.subtitle == self.stringFromAddressDictionary(mapItem.placemark.addressDictionary)
            let coordinateMatch = $0.coordinate.latitude == mapItem.placemark.coordinate.latitude && $0.coordinate.longitude == mapItem.placemark.coordinate.longitude
            return nameMatch && addressMatch && coordinateMatch
        })
        
        mapView?.removeAnnotations(annotation)
    }
    
    /**
        Removes a map item from the table view and deletes from the selected locations.
    
        :param: indexPath The index path of the map item to remove from the table view and selected locations list.
    */
    private func removeMapItemFromTableView(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        selectedLocations.removeAtIndex(indexPath.row)
        tableView.endUpdates()
    }
    
    /**
        Makes an address string out of the available information in the address dictionary.
    
        :param: addressDictionary A dictionary of address information.
    */
    private func stringFromAddressDictionary(addressDictionary: [NSObject: AnyObject]) -> String {
        return ABCreateStringWithAddressDictionary(addressDictionary, false).stringByReplacingOccurrencesOfString("\n", withString: " ")
    }
    
    // MARK: - Methods related to exiting view controller.
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let changeEventViewController = navigationController!.viewControllers.first as? ChangeEventViewController
        changeEventViewController?.updateLocations(selectedLocations)
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
        return .Delete
    }
    
    /**
        If searching, selection will append to selected locations and clear the search bar. If not searching, selection will center the map on the selected location.
    
        The filter ensures that search results will not show locations that are already selected, so this method cannot add duplicate locations.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searching() {
            let mapItem = filteredLocations[indexPath.row]
            addNewMapItem(mapItem)
        }
        else {
            let mapItem = selectedLocations[indexPath.row]
            NSNotificationCenter.defaultCenter().postNotificationName("LocationChanged", object: self, userInfo: ["Location": mapItem.placemark.location])
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
        if searching() {
            return filteredLocations.count
        }
        return selectedLocations.count
    }
    
    /**
        Allow table cells to be deleted.
    
        Note: If tableView.editing = true, the left circular edit option will appear. If contacts are being searched, the table cannot be edited.
    */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if searching() {
            return false
        }
        return true
    }
    
    /**
        Selected locations can be removed by swiping left and pressing delete.
    */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteSelectedMapItem(selectedLocations[indexPath.row], atIndexPath: indexPath)
        }
    }
    
    /**
        Display cell with name as text label and phone number as detail text label. If searching, show a LocationCell for the filtered location. If not searching, show a LocationCell for the selected location.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! UITableViewCell
        
        if searching() {
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
    /**
        When the search bar is activated or the text in the search bar changes, start updating search results. Search results cannot be duplicates of already-selected locations.
    
        TODO: disable selecting from selected locations when waiting to load results and still showing selected locations.
    */
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Destroy last request and make a new one
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "filterLocations:", userInfo: searchController.searchBar.text, repeats: false)
        tableView.reloadData()
    }
}