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
    
    // Directions being shown by table view. If nil, table view does not show directions.
    var directions: [MKRouteStep]?
    
    // If true, the table view is showing directions to a location. If false, the table view is showing locations.
    var showingDirections: Bool {
        if directions != nil {
            return true
        }
        return false
    }
    
    var selectedMapItems: [MapItem]!

    weak var mapView: MKMapView?

    private let reuseIdentifier = "LocationCell"
    
    // Search request timer used to provide delay between search requests.
    private var timer: NSTimer?
    
    var contactIDs: Set<ABRecordID>?
    private var addressBookRef: ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue()
    
    // MARK: - Methods for setting up view controller.
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "toggleDirections:", name: "DirectionsRequested", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "toggleDirections:", name: "DirectionsDismissed", object: nil)
    }
    
    /**
        Sets table view delegate and data source, initializes the selected map items to be empty if no map items were initially passed in, and creates search controller if editing is enabled.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.registerClass(TwoDetailTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.bounces = false
        tableView.alwaysBounceVertical = false
        
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
        selectedMapItems = mapItems
        
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
    
    // MARK: - Methods related to showing and hiding direction.
    
    /**
        Shows directions when notified.
    
        :param: notification The notification that the table view should show directions.
    */
    func toggleDirections(notification: NSNotification) {
        directions = notification.userInfo?["Directions"] as? [MKRouteStep]
        
        // Reload table view with directions (if there are any) or with locations (if directions = nil).
        tableView.reloadData()
    }
    
    func displayLocationNotFoundAlert(address: String) {
        if presentingViewController == nil {
            let alertController = UIAlertController(title: "Invalid contact address", message: "\(address) was not found. Check that it is a valid address.", preferredStyle: .Alert)
            let okAlertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okAlertAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
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
        Selecting a location will send out a notification that a map item was selected. Selecting a direction will send out a notification that a direction was selected.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Select either direction or location.
        
        if showingDirections {
            // If selecting a direction, send a notice that
            let direction = directions![indexPath.row]
            NSNotificationCenter.defaultCenter().postNotificationName("DirectionSelected", object: self, userInfo: ["Direction": direction])
        }
        else {
            let mapItem = selectedMapItems[indexPath.row]
            NSNotificationCenter.defaultCenter().postNotificationName("MapItemSelected", object: self, userInfo: ["MapItem": mapItem])
        }
        
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
        if showingDirections {
            return directions!.count
        }
        return selectedMapItems.count
    }
    
    /**
        Display cell with name as text label and address as detail text label.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! TwoDetailTableViewCell
        cell.removeAllWidthConstraints()
        
        // Use cell for either showing direction or location.
        
        if showingDirections {
            // If showing directions, main label shows instruction.
            let direction = directions![indexPath.row]
            cell.mainLabel.text = direction.instructions
            cell.subLabel.text = nil
            cell.detailLabel.text = nil
            cell.subLabel.sizeToFit()
            cell.detailLabel.sizeToFit()
        }
        else {
            // If showing locations, main label shows name and detail label shows address.
            let mapItem = selectedMapItems[indexPath.row]
            let name = mapItem.name
            let address = mapItem.address
            cell.mainLabel.text = name
            cell.subLabel.text = address
            cell.detailLabel.text = nil
            cell.subLabel.sizeToFit()
            cell.detailLabel.sizeToFit()
        }
        
        return cell
    }
    
    
    // MARK: - Methods related to editing.
    
    /**
        Allow table cells to be deleted by swiping left for a delete button if editing is enabled.
    
        Note: If `tableView.editing = true`, the left circular edit option will appear. If locations are being searched or editing is disabled, the table cannot be edited.
    */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if editingEnabled && !showingDirections {
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

// MARK: - ContactsTableViewControllerDelegate
extension LocationsTableViewController: ContactsTableViewControllerDelegate {
    func contactsTableViewControllerDidUpdateContacts(contactIDs: [ABRecordID]) {
        if self.contactIDs == nil {
            self.contactIDs = Set<ABRecordID>()
        }
        
        for contactID in contactIDs {
            if let contact: ABRecordRef = ABAddressBookGetPersonWithRecordID(addressBookRef, contactID)?.takeUnretainedValue() {
                if let addressDictionary = ContactsTableViewController.getAddressDictionary(contact) {
                    
                    CLGeocoder().geocodeAddressDictionary(addressDictionary, completionHandler: {
                        (placemarks: [AnyObject]?, error: NSError?) in
                        if let error = error {
                            // Give description of error if there is one.
                            NSLog("Error occurred when geocoding contact address :%@", error.localizedDescription)
                        }
                        else {
                            // Add contact address to map items.
                            let clPlacemark = placemarks!.first as! CLPlacemark
                            let mkPlacemark = MKPlacemark(placemark: clPlacemark)
                            let mkMapItem = MKMapItem(placemark: mkPlacemark)
                            if let contactName = ABRecordCopyCompositeName(contact)?.takeRetainedValue() {
                                mkMapItem.name = contactName as String
                            }
                            
                            // Create and add new map item only if found address matches dictionary address.
                            if MapItem.stringFromAddressDictionary(mkMapItem.placemark.addressDictionary) == MapItem.stringFromAddressDictionary(addressDictionary) {
                                self.contactIDs!.insert(contactID)
                                
                                let mapItem = MapItem(mkMapItem: mkMapItem)
                                
                                if !contains(self.selectedMapItems, mapItem) {
                                    self.addNewMapItem(mapItem)
                                }
                            }
                            // Otherwise, give warning that address was not found.
                            else {
                                self.displayLocationNotFoundAlert(MapItem.stringFromAddressDictionary(addressDictionary))
                            }
                        }
                    })
                }
            }
        }
        
        let contactIDsArray = Array(self.contactIDs!)
        let removedContactIDs = contactIDsArray.filter({
            if !contains(contactIDs, $0) {
                return true
            }
            return false
        })
        
        for removedContactID in removedContactIDs {
            if let contact: ABRecord = ABAddressBookGetPersonWithRecordID(addressBookRef, removedContactID)?.takeUnretainedValue() {
                
                if let addressDictionary = ContactsTableViewController.getAddressDictionary(contact) {
                    let address = MapItem.stringFromAddressDictionary(addressDictionary)
                    let removedMapItem = selectedMapItems.filter({
                        println($0.address)
                        println(address)
                        return $0.address == address
                    }).first
                    if let removedMapItem = removedMapItem {
                        self.contactIDs!.remove(removedContactID)
                        let mapItemIndex = find(selectedMapItems, removedMapItem)
                        let indexPath = NSIndexPath(forRow: mapItemIndex!, inSection: 0)
                        deleteSelectedMapItem(removedMapItem, atIndexPath: indexPath)
                    }
                }
            }
        }
    }
}