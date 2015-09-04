//
//  LocationsViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/3/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import AddressBook

class LocationsViewController: UIViewController {
    var delegate: LocationsTableViewControllerDelegate?
    
    @IBOutlet weak var locationsMapViewContainer: UIView!
    @IBOutlet weak var locationsTableViewContainer: UIView!
    
    @IBOutlet weak var contactsBarButtonItem: UIBarButtonItem!
    
    private let locationManager = CLLocationManager()
    
    private weak var mapView: MKMapView?
    
    private let locationsTableViewSegue = "LocationsTableViewSegue"
    private let locationsMapViewSegue = "LocationsMapViewSegue"
    
    var locationsTableViewController: LocationsTableViewController!
    var locationsMapViewController: LocationsMapViewController!

    var editingEnabled: Bool?
    
    var event: LZEvent!
    
    // MARK: - Methods for initialization.
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setMapView:", name: "MapViewLoaded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showEventNotification:", name: "EventNotificationReceived", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadData", name: "applicationBecameActive", object: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self

        initializeContactsBarButtonItem()
        
        initializeHeightConstraints()
    }
    
    /**
        Initializes the contacts bar button item to show or hide based on whether or not there are selected contacts. If there are selected contacts, show the button. If not, hide the button.
    */
    private func initializeContactsBarButtonItem() {
        if event.contacts.count > 0 {
            // Show the button if there are contacts.
            contactsBarButtonItem.enabled = true
            contactsBarButtonItem.title = "Contacts"
        }
        else {
            // Otherwise hide the button.
            contactsBarButtonItem.enabled = false
            contactsBarButtonItem.title = nil
        }
    }

    /**
        Initialize height constraints on the map view. The height constraints are determined by device size while the table view container takes up the remaining space.
    
        The map's height is 1/3 of the screen.
    */
    private func initializeHeightConstraints() {
        let heightConstraint = NSLayoutConstraint(item: locationsMapViewContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: view.frame.height / 3)
        locationsMapViewContainer.addConstraint(heightConstraint)
    }
    
    /**
        Sets the map view.
    
        :param: notification The notification that the map view has loaded.
    */
    func setMapView(notification: NSNotification) {
        mapView = notification.userInfo!["MapView"] as? MKMapView
    }
    
    // MARK: - Methods for loading data.
    
    func loadData(#event: LZEvent) {
        self.event = event
    }
    
    // MARK: - Methods for segueing.
    
    /**
        When the contacts bar button item is pressed, check if address book access is given and show the contacts table view controller if it is granted. If not, display an alert.
    
        :param: sender The event sender.
    */
    @IBAction func contactsBarButtonItemPressed(sender: AnyObject) {
        if let sender = sender as? UIBarButtonItem {
            if addressBookAccessible() {
                showContactsTableViewController()
            }
            else {
                displayAddressBookInaccessibleAlert()
            }
        }
    }
    
    /**
        Shows the contacts table view controller.
    
        This method is called when the contacts bar button item is pressed. If the user has given access to their address book, the `ContactsTableViewController` is shown. Otherwise, this method will do nothing.
    */
    func showContactsTableViewController() {
        if addressBookAccessible() {
            // Check if app has access to address book.
            
            // Create contacts table view controller.
            let contactsTableViewController = storyboard!.instantiateViewControllerWithIdentifier("ContactsTableViewController") as! ContactsTableViewController
            
            contactsTableViewController.addressMode = true
            contactsTableViewController.editingEnabled = false
            
            let selectedContacts = Array(locationsTableViewController.contacts)
            contactsTableViewController.loadData(event: event, selectedContacts: selectedContacts)
            contactsTableViewController.delegate = locationsTableViewController
            
            // Show view controller.
            navigationController!.showViewController(contactsTableViewController, sender: self)
        }
    }
    
    /**
        When locations table view is about to be created, set map view and load initial map items. Also set `locationsTableViewController` and `locationsMapViewController` fields.
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let identifier = segue.identifier {
            if identifier == locationsTableViewSegue {
                locationsTableViewController = segue.destinationViewController as! LocationsTableViewController
                
                // Set map, map items, and editing enabled for table view controller.
                locationsTableViewController.mapView = mapView
                locationsTableViewController.loadData(event: event)
                locationsTableViewController.delegate = delegate
                if let editingEnabled = editingEnabled {
                    locationsTableViewController.editingEnabled = editingEnabled
                }
            }
            else if identifier == locationsMapViewSegue {
                locationsMapViewController = segue.destinationViewController as! LocationsMapViewController
            }
        }
    }
    
    /**
        Checks if the user location is accessible. If not, display an alert.
    */
    func reloadData() {
        if isViewLoaded() && view?.window != nil {
            if !locationAccessible() {
                displayLocationInaccessibleAlert()
            }
        }
    }
    
    /**
        When the user location is inaccessible, display an alert stating that the location is inaccessible.
    
        If the user chooses the "Settings" option, they can change their settings. If the user chooses "Exit", they leave the locations view and return to the previous view.
    */
    override func displayLocationInaccessibleAlert() {
        let alertController = UIAlertController(title: "Cannot Access User Location", message: "You must give permission to access locations to use this feature.", preferredStyle: .Alert)
        let settingsAlertAction = UIAlertAction(title: "Settings", style: .Default, handler: {
            action in
            self.openSettings()
        })
        let exitAlertAction = UIAlertAction(title: "Exit", style: .Default, handler: {
            action in
            navigationController!.popViewControllerAnimated(true)
        })
        alertController.addAction(exitAlertAction)
        alertController.addAction(settingsAlertAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationsViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Denied, .Restricted:
            displayLocationInaccessibleAlert()
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
}