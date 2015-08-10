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

    private var selectedMapItems: [MapItem]!
    private var filteredMapItems = [MapItem]()
    
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
        
        if selectedMapItems == nil {
            selectedMapItems = [MapItem]()
        }
        /*if annotations == nil {
            annotations = [MKPointAnnotation]()
        }
        */
        
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
    func loadData(mapItems: [MapItem]) {
        self.selectedMapItems = mapItems
        
        // Convert map items to annotations
        /*annotations = selectedLocations.map({
            mapItem in
            let annotation = MKPointAnnotation()
            annotation.title = mapItem.name
            let address = self.stringFromAddressDictionary(mapItem.placemark.addressDictionary)
            annotation.subtitle = address
            annotation.coordinate = mapItem.placemark.coordinate
            return annotation
        })*/
        
        // Add all annotations to map view.
        mapView?.addAnnotations(selectedMapItems)
        /*mapView?.addAnnotations(annotations)*/
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
                    let mkMapItems = response.mapItems as! [MKMapItem]
                    let mapItems = mkMapItems.map({
                        return MapItem(coordinate: $0.placemark.coordinate, name: $0.name, address: self.stringFromAddressDictionary($0.placemark.addressDictionary))
                    })
                    self.filteredMapItems = mapItems.filter({
                        !contains(self.selectedMapItems, $0)
                    })
                    // Remove all search results that already exist in selectedLocations
                    /*self.filteredLocations = mapItems.filter({
                        !contains(self.selectedMapItems, $0)
                    })*/
                    
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
        Adds a new map item.
    
        The new map item annotation is added to the map view and the map item is appended to the table view.
    */
    private func addNewMapItem(mapItem: MapItem) {
        addMapItemToMapView(mapItem)
        selectedMapItems.append(mapItem)
        searchController?.searchBar.text = nil
    }
    
    /**
        Shows an annotation at the map item's location with displayed information about the map item.
    
        :param: mapItem The map item to show on the map view.
    */
    private func addMapItemToMapView(mapItem: MapItem) {
        /*let annotation = MKPointAnnotation()
        annotation.title = mapItem.name
        let address = stringFromAddressDictionary(mapItem.placemark.addressDictionary)
        annotation.subtitle = address
        annotation.coordinate = mapItem.placemark.coordinate*/
        
        mapView?.addAnnotation(mapItem)
        /*annotations.append(annotation)*/
    }
    
    // MARK: - Methods for removing map items.
    
    /**
        Deletes a selected map item.
    
        The map item annotation is removed from the map view and the map item is removed from the table view.
    
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
        /*let annotation = annotations.filter({
            let nameMatch = $0.title == mapItem.name
            let addressMatch = $0.subtitle == self.stringFromAddressDictionary(mapItem.placemark.addressDictionary)
            let coordinateMatch = $0.coordinate.latitude == mapItem.placemark.coordinate.latitude && $0.coordinate.longitude == mapItem.placemark.coordinate.longitude
            return nameMatch && addressMatch && coordinateMatch
        }).first as? MKPointAnnotation*/
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
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let changeEventViewController = navigationController!.viewControllers.first as? ChangeEventViewController
        changeEventViewController?.updateMapItems(selectedMapItems)
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
            return filteredMapItems.count
        }
        return selectedMapItems.count
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
            deleteSelectedMapItem(selectedMapItems[indexPath.row], atIndexPath: indexPath)
        }
    }
    
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
}

// MARK: - UISearchResultsUpdating
extension LocationsTableViewController: UISearchResultsUpdating {
    /**
        When the search bar is activated or the text in the search bar changes, start updating search results. Search results cannot be duplicates of already-selected locations.
    */
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Destroy last request and make a new one
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "filterLocations:", userInfo: searchController.searchBar.text, repeats: false)
        tableView.reloadData()
    }
}