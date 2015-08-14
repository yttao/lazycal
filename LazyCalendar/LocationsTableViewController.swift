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
    var editingEnabled = true
    
    var selectedMapItems: [MapItem]!
    // Map items shown when searching for locations
    private var filteredMapItems = [MapItem]()

    weak var mapView: MKMapView?

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
        
        //tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    /**
        Initializes the search controller.
    */
    private func initializeSearchController() {
        // Create search controller.
        let searchController: SearchController = {
            let controller = SearchController(searchResultsController: nil)
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.searchBarStyle = .Default
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Search for Places"
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
            }()
        
        // Set up the search table view.
        
        // Offset the search table view so that it is below the search bar.
        let offset = CGRectOffset(searchController.searchBar.frame, 0, searchController.searchBar.frame.height)
        let frame = CGRectMake(offset.origin.x, offset.origin.y, tableView.frame.width, 0)
        let searchTableView = LocationsSearchTableView(frame: frame, style: .Plain)
        searchTableView.loadData(selectedResultsTableViewController: self, searchController: searchController)
        
        // Set search table view as delegate.
        searchController.searchControllerDelegate = searchTableView
        searchController.searchResultsUpdater = searchTableView
        
        // Overlay search table view on top of selected contacts table view.
        view.insertSubview(searchTableView, aboveSubview: tableView)
        view.didAddSubview(searchTableView)
        
        // If search bar is active, presentation context must be defined. If this is not done, the search bar will not be dismissed properly and will be visible in views other than the locations view.
        definesPresentationContext = true
    }
    
    // MARK: - Methods related to initializing data.
    
    /**
        Loads initial selected locations.
    
        :param: mapItems The initial selected map items.
    */
    func loadData(mapItems: [MapItem]) {
        self.selectedMapItems = mapItems
        
        // Add all annotations to map view.
        mapView?.addAnnotations(selectedMapItems)
    }
    
    // MARK: - Methods for adding map items.
    
    /**
        Adds a new map item to the map item's location and the table view.
    
        The map item is added to the map view and the table view.
    */
    func addNewMapItem(mapItem: MapItem) {
        addMapItemToMapView(mapItem)
        addMapItemToTableView(mapItem)
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
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: selectedMapItems.count, inSection: 0)], withRowAnimation: .Automatic)
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
        Selection will send out a notification that the location to focus on has changed and center the map on the selected location.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mapItem = selectedMapItems[indexPath.row]
        NSNotificationCenter.defaultCenter().postNotificationName("LocationChanged", object: self, userInfo: ["Location": mapItem.location])
    }
    
    // MARK: - Methods for setting up headers and footers.
    
    /**
        Hide footer view.
    */
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRectZero)
    }
    
    /**
        Footer height is zero.
    */
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(Math.epsilon)
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
        The number of rows is the number of selected map items.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedMapItems.count
    }
    
    /**
        Display cell with name as text label and address as detail text label.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! UITableViewCell
        
        let mapItem = selectedMapItems[indexPath.row]
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
        if editingEnabled {
            return true
        }
        return false
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