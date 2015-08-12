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
    private var editingEnabled = true
    
    private var selectedMapItems: [MapItem]!
    // Map items shown when searching for locations
    private var filteredMapItems = [MapItem]()

    private weak var mapView: MKMapView?

    private let reuseIdentifier = "LocationCell"
    
    // Search request timer used to provide delay between search requests.
    private var timer: NSTimer?
    
    // MARK: - Methods for setting up view controller.
    
    /**
        Sets table view delegate and data source, initializes the selected map items to be empty if no map items were initially passed in, and creates search controller if editing is enabled.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if selectedMapItems == nil {
            selectedMapItems = [MapItem]()
        }
        
        if editingEnabled {
            initializeSearchController()
        }
    }
    
    /**
        Initializes the search controller.
    */
    private func initializeSearchController() {
        searchController = {
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Search for Locations"
            controller.hidesNavigationBarDuringPresentation = false
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        }()
        
        // If search bar is active, presentation context must be defined. If this is not done, the search bar will not be dismissed properly and will be visible in views other than the locations view.
        definesPresentationContext = true
    }
    
    // MARK: - Methods related to initializing data.
    
    /**
        Sets whether editing is enabled or not. If editing is enabled, locations can be added and removed. Otherwise, the selected locations are fixed.
    
        :param: enabled `true` if editing is enabled; `false` otherwise.
    */
    func setEditingEnabled(enabled: Bool) {
        editingEnabled = enabled
    }
    
    /**
        Loads initial selected locations.
    
        :param: mapItems The initial selected map items.
    */
    func loadData(mapItems: [MapItem]) {
        self.selectedMapItems = mapItems
        
        // Add all annotations to map view.
        mapView?.addAnnotations(selectedMapItems)
    }
    
    /**
        Sets the map view for the map items to appear in.
    
        :param: mapView The `MKMapView` used by the `LocationsViewController`.
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
    
        :param: timer The `NSTimer` controlling when the search request fires.
    */
    func filterLocations(timer: NSTimer) {
        let searchText = timer.userInfo as? String
        
        if searching() {
            // Create search request.
            let request = MKLocalSearchRequest()
            // Set text to search for.
            request.naturalLanguageQuery = searchText
            // Set location to begin searching from.
            request.region = mapView!.region
            
            // Search for string.
            let search = MKLocalSearch(request: request)
            search.startWithCompletionHandler() {
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
                        return MapItem(coordinate: $0.placemark.coordinate, name: $0.name, address: self.stringFromAddressDictionary($0.placemark.addressDictionary))
                    })
                    // Show only MapItems that aren't already present in selected map items.
                    self.filteredMapItems = mapItems.filter({
                        !contains(self.selectedMapItems, $0)
                    })
                }
                self.tableView.reloadData()
            }
        }
        else {
            filteredMapItems.removeAll(keepCapacity: false)
            tableView.reloadData()
        }
    }
    
    // MARK: - Methods for adding map items.
    
    /**
        Adds a new map item to the map item's location and the table view.
    
        The map item is added to the map view and the table view.
    */
    private func addNewMapItem(mapItem: MapItem) {
        addMapItemToMapView(mapItem)
        addMapItemToTableView(mapItem)
        searchController?.searchBar.text = nil
    }
    
    /**
        Adds an annotation to the map item's location with displayed information about the map item.
    
        :param: mapItem The `MapItem` to show on the map view.
    */
    private func addMapItemToMapView(mapItem: MapItem) {
        mapView?.addAnnotation(mapItem)
    }
    
    /**
        Adds a map item to the table view.
    
        :param: mapItem The `MapItem` to add to the table view.
    */
    private func addMapItemToTableView(mapItem: MapItem) {
        tableView.beginUpdates()
        selectedMapItems.append(mapItem)
        tableView.endUpdates()
    }
    
    // MARK: - Methods for deleting map items.
    
    /**
        Deletes a selected map item from the map view and the table view.
    
        :param: mapItem The map item to delete.
        :param: indexPath The index path of the deleted map item.
    */
    private func deleteSelectedMapItem(mapItem: MapItem, atIndexPath indexPath: NSIndexPath) {
        removeMapItemFromMapView(mapItem)
        removeMapItemFromTableView(indexPath)
    }
    
    /**
        Removes the annotation at the map item's location.
    
        :param: mapItem The map item to remove from the map view.
    */
    private func removeMapItemFromMapView(mapItem: MapItem) {
        let annotation = selectedMapItems.filter({
            $0 == mapItem
        }).first
        
        mapView?.removeAnnotation(annotation)
    }
    
    /**
        Removes a map item from the table view and deletes from the selected locations.
    
        :param: indexPath The index path of the map item to remove from the table view and selected locations list.
    */
    private func removeMapItemFromTableView(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        selectedMapItems.removeAtIndex(indexPath.row)
        tableView.endUpdates()
    }
    
    // MARK: - Methods for formatting data.
    
    /**
        Makes an address string out of the available information in the address dictionary.
    
        The address string is created in two steps:
    
        * Create a multiline address with all information.
    
        The address string created by `ABCreateStringWithAddressDictionary:` is a multiline address usually created the following format (if any parts of the address are unavailable, they do not appear):
    
        Street address
    
        City State Zip code
    
        Country
    
        * Replace newlines with spaces.
        
        The newlines are then replaced with spaces using `stringByReplacingOccurrencesOfString:withString:` because the `subtitle` property of `MKAnnotation` can only display single line strings.
    
        :param: addressDictionary A dictionary of address information.
    */
    private func stringFromAddressDictionary(addressDictionary: [NSObject: AnyObject]) -> String {
        return ABCreateStringWithAddressDictionary(addressDictionary, false).stringByReplacingOccurrencesOfString("\n", withString: " ")
    }
    
    // MARK: - Methods related to exiting view controller.
    
    /**
        When the view is about to disappear, if it segues back to a ChangeEventViewController, update the map items for the event.
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let changeEventViewController = navigationController!.viewControllers.first as? ChangeEventViewController
        changeEventViewController?.updateMapItems(selectedMapItems)
    }
}

// MARK: - UITableViewDelegate
extension LocationsTableViewController: UITableViewDelegate {
    // MARK: - Methods related to selecting cells.
    
    /**
        If searching, selection will append to selected locations and clear the search bar. If not searching, selection will send out a notification that the location to focus on has changed and center the map on the selected location.
    
        The filter ensures that search results will not show locations that are already selected, so this method cannot add duplicate locations.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searching() {
            let mapItem = filteredMapItems[indexPath.row]
            addNewMapItem(mapItem)
        }
        else {
            let mapItem = selectedMapItems[indexPath.row]
            NSNotificationCenter.defaultCenter().postNotificationName("LocationChanged", object: self, userInfo: ["Location": mapItem.location])
        }
    }
    
    // MARK: - Methods related to editing appearance.
    
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
}

// MARK: - UITableViewDataSource
extension LocationsTableViewController: UITableViewDataSource {
    // MARK: - Methods for setting up amount of sections and cells.
    
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
            return filteredMapItems.count
        }
        return selectedMapItems.count
    }
    
    // MARK: - Methods for setting up cell content.
    
    /**
        Display cell with name as text label and phone number as detail text label. If searching, show a LocationCell for the filtered location. If not searching, show a LocationCell for the selected location.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! UITableViewCell
        
        let mapItem: MapItem
        if searching() {
            mapItem = filteredMapItems[indexPath.row]
            
        }
        else {
            mapItem = selectedMapItems[indexPath.row]
        }
        let name = mapItem.name
        let address = mapItem.address
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = address
        
        return cell
    }
    
    
    // MARK: - Methods related to editing.
    
    /**
        Allow table cells to be deleted by swiping left for a delete button.
    
        Note: If `tableView.editing = true`, the left circular edit option will appear. If locations are being searched or editing is disabled, the table cannot be edited.
    */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if searching() || !editingEnabled {
            return false
        }
        return true
    }
    
    /**
        If the delete button is pressed, the selected map item is deleted.
    */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteSelectedMapItem(selectedMapItems[indexPath.row], atIndexPath: indexPath)
        }
    }
}

// MARK: - UISearchResultsUpdating
extension LocationsTableViewController: UISearchResultsUpdating {
    /**
        When the search bar is activated or the text in the search bar changes, start updating search results.
    
        Search results are controlled by an NSTimer. Whenever this function is called, the last timer used is invalidated in order to prevent sending previous search requests when the text to search has changed. Then, it begins a new timer that waits 0.3 seconds before starting a search request.
    */
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Destroy last request and make a new one
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "filterLocations:", userInfo: searchController.searchBar.text, repeats: false)
        tableView.reloadData()
    }
}