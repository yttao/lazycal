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
    var delegate: LocationsTableViewControllerDelegate?
    
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

    weak var mapView: MKMapView?

    private let reuseIdentifier = "LocationCell"
    
    // Search request timer used to provide delay between search requests.
    private var timer: NSTimer?
    
    var contacts = Set<LZContact>()
    private var addressBookRef: ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue()
    
    var selectedIndexPath: NSIndexPath?
    var event: LZEvent!
    
    var storedLocations: NSMutableOrderedSet {
        return event.mutableOrderedSetValueForKey("locations")
    }
    
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
        
        if editingEnabled {
            initializeSearchController()
        }
        
        // Get the contacts that are already selected.
        let contactsArray = event.storedContacts.array as! [LZContact]
        let locationsArray = event.storedLocations.array as! [LZLocation]
        
        // Go through all event contacts that have at least one location.
        let contactsWithLocations = contactsArray.filter({
            return $0.storedLocations.count > 0
        })
        
        for contact in contactsWithLocations {
            let contactLocations = contact.storedLocations.allObjects as! [LZLocation]

            for contactLocation in contactLocations {
                // If the event has a location that matches the contact's location, the contact is already selected.
                if contains(locationsArray, contactLocation) {
                    contacts.insert(contact)
                }
            }
            
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
    func loadData(#event: LZEvent) {
        self.event = event
        let locationsArray = storedLocations.array as! [LZLocation]
        // Add all annotations to map view.
        mapView?.addAnnotations(locationsArray)
    }
    
    // MARK: - Methods for adding map items.
    
    /**
        Adds a new location to the map view, the table view, and the event.
    
        :param: location The location to add.
    */
    func addLocation(#location: LZLocation) {
        addLocationToMapView(location)
        addLocationToTableView(location)
    }
    
    /**
        Adds an annotation to the map item's location with displayed information about the map item.
    
        :param: location The location to show on the map view.
    */
    private func addLocationToMapView(location: LZLocation) {
        mapView?.addAnnotation(location)
    }
    
    /**
        Adds a map item to the table view.
    
        :param: location The location to add to the table view.
    */
    private func addLocationToTableView(location: LZLocation) {
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: storedLocations.count, inSection: 0)], withRowAnimation: .Automatic)
        event.addLocation(location)
        tableView.endUpdates()
    }
    
    // MARK: - Methods for deleting map items.
    
    /**
        Removes a location from the map view, the table view, and the event.
    
        :param: mapItem The map item to delete.
        :param: indexPath The index path of the deleted map item.
    */
    func removeLocation(location: LZLocation, atIndexPath indexPath: NSIndexPath) {
        removeLocationFromMapView(location)
        removeLocationFromTableView(location, atIndexPath: indexPath)
    }
    
    /**
        Removes a location from the map view, the table view, and the event.
    */
    func removeLocation(location: LZLocation) {
        // Find index of location in stored locations and remove.
        let index = event.storedLocations.indexOfObject(location)
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        removeLocation(location, atIndexPath: indexPath)
    }
    
    /**
        Removes the annotation at the map item's location.
    
        :param: mapItem The map item to remove from the map view.
    */
    private func removeLocationFromMapView(location: LZLocation) {
        let locationsArray = storedLocations.array as! [LZLocation]
        let annotation = locationsArray.filter({
            $0 == location
        }).first
        
        mapView?.removeAnnotation(annotation)
    }
    
    /**
        Returns a `Bool` indicating if the location is already selected.
    
        :param: mapItem The map item to test.
        :returns: `true` if the location is selected; `false` otherwise.
    */
    func locationSelected(mapItem: MKMapItem) -> Bool {
        let coordinate = mapItem.placemark.coordinate
        let address = LZLocation.stringFromAddressDictionary(mapItem.placemark.addressDictionary)
        let name = mapItem.name
        
        let locationsArray = storedLocations.array as! [LZLocation]
        let locationMatch = locationsArray.filter({
            let latitudeMatch = fabs($0.latitude - coordinate.latitude) < Math.epsilon
            let longitudeMatch = fabs($0.longitude - coordinate.longitude) < Math.epsilon
            let coordinateMatch = latitudeMatch && longitudeMatch
            let addressMatch = $0.address == address
            let nameMatch = $0.name == name
            return coordinateMatch && addressMatch && nameMatch
        })
        
        return !locationMatch.isEmpty
    }
    
    /**
        Removes a map item from the table view and deletes from the selected locations.
    
        :param: indexPath The index path of the map item to remove from the table view and selected locations list.
    */
    private func removeLocationFromTableView(location: LZLocation, atIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        event.removeLocation(location)
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
        
        // If returning to showing map items and a map item was previously selected, reselect it.
        if selectedIndexPath != nil && !showingDirections {
            tableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: .None)
        }
    }
    
    /**
        Adds the contact's address to the list of locations.
    
        :param: contact The contact to get the address from.
    */
    func addContactAddress(contact: LZContact) {
        self.contacts.insert(contact)
        
        // Get the contact's address dictionary.
        let recordRef: ABRecordRef? = contact.getABRecordRef()
        
        // Check if the contact has an address dictionary to geocode.
        if let addressDictionary = ContactsTableViewController.getAddressDictionary(recordRef!) {
            // Geocode address
            CLGeocoder().geocodeAddressDictionary(addressDictionary, completionHandler: {
                (placemarks: [AnyObject]?, error: NSError?) in
                if let error = error {
                    // Give description of error if there is one.
                    NSLog("Error occurred when geocoding contact address :%@", error.localizedDescription)
                }
                else {
                    // Get all found placemarks.
                    let placemarks = placemarks as! [CLPlacemark]
                    
                    // Take first as assumed correct address (TODO: improve this somehow).
                    let placemark = placemarks.first
                    
                    // Make MKPlacemark.
                    let mkPlacemark = MKPlacemark(placemark: placemark)
                    let mapItem = MKMapItem(placemark: mkPlacemark)
                    
                    // Set contact's name as map item name.
                    if let contactName = ABRecordCopyCompositeName(contact.getABRecordRef())?.takeRetainedValue() as? String {
                        mapItem.name = contactName
                    }
                    
                    // Add location.
                    if let storedLocation = LZLocation.getStoredLocation(mapItem.placemark.coordinate) {
                        // If location already exists, just add stored location.
                        self.addLocation(location: storedLocation)
                        contact.addLocation(storedLocation)
                    }
                    else {
                        let newLocation = LZLocation(mkMapItem: mapItem)
                        self.addLocation(location: newLocation)
                        contact.addLocation(newLocation)
                    }
                }
            })
        }
    }
    
    /**
        Removes a contact's address from the list of locations.
    */
    func removeContactAddress(contact: LZContact) {
        self.contacts.remove(contact)
        
        // Remove all contact relations to location and remove location from the location view.
        let contactLocations = contact.storedLocations.allObjects as! [LZLocation]
        for location in contactLocations {
            contact.removeLocation(location)
            removeLocation(location)
        }
    }
    
    func displayLocationNotFoundAlert(address: String) {
        if presentedViewController == nil {
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
        
        let locationsArray = storedLocations.array as! [LZLocation]
        delegate?.locationsTableViewControllerDidUpdateLocations(locationsArray)
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
            let location = storedLocations[indexPath.row] as! LZLocation
            NSNotificationCenter.defaultCenter().postNotificationName("LocationSelected", object: self, userInfo: ["Location": location])
            selectedIndexPath = indexPath
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
        return storedLocations.count
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
            if direction.instructions != "" {
                cell.mainLabel.text = direction.instructions
            }
            else {
                cell.mainLabel.text = " "
            }
            cell.subLabel.text = " "
            cell.detailLabel.text = " "
        }
        else {
            // If showing locations, main label shows name and detail label shows address.
            let location = storedLocations[indexPath.row] as! LZLocation
            if let name = location.name {
                cell.mainLabel.text = name
            }
            else {
                cell.mainLabel.text = " "
            }
            if let address = location.address {
                cell.subLabel.text = address
            }
            else {
                cell.subLabel.text = " "
            }
            cell.detailLabel.text = " "
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
            let location = storedLocations[indexPath.row] as! LZLocation
            removeLocation(location, atIndexPath: indexPath)
        }
    }
}

// MARK: - ContactsTableViewControllerDelegate
extension LocationsTableViewController: ContactsTableViewControllerDelegate {
    func contactsTableViewControllerDidUpdateContacts(contacts: [LZContact]) {
        // Get all contacts that were added.
        let addedContacts = contacts.filter({
            if !contains(self.contacts, $0) {
                return true
            }
            return false
        })
        
        // Add all new contacts.
        for contact in addedContacts {
            // Add the contact's address.
            addContactAddress(contact)
        }
        
        // Get all the contacts that were removed.
        let contactsArray = Array(self.contacts)
        let removedContacts = contactsArray.filter({
            if !contains(contacts, $0) {
                return true
            }
            return false
        })
        
        // Remove all old contacts.
        for contact in removedContacts {
            removeContactAddress(contact)
        }
    }
}

protocol LocationsTableViewControllerDelegate {
    /**
        Informs the delegate that the locations table view controller updated its locations.
    */
    func locationsTableViewControllerDidUpdateLocations(locations: [LZLocation])
}