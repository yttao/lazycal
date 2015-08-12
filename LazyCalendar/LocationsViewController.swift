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

class LocationsViewController: UIViewController {
    @IBOutlet weak var locationsMapViewContainer: UIView!
    @IBOutlet weak var locationsTableViewContainer: UIView!
    
    private let locationManager = CLLocationManager()
    
    private weak var mapView: MKMapView?
    
    private let locationsTableViewSegue = "LocationsTableViewSegue"
    private let locationsMapViewSegue = "LocationsMapViewSegue"
    
    private var mapItems: [MapItem]?
    private var editingEnabled: Bool?
    
    // MARK: - Methods for initializing view controller and data.
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setMapView:", name: "MapViewLoaded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showEventNotification:", name: "EventNotificationReceived", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkLocationAccessibility", name: "applicationBecameActive", object: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        initializeHeightConstraints()
    }
    
    /**
        Loads initial data about map items in the view.
    
        :param: mapItems The initial map items in the view.
    */
    func loadData(mapItems: [MapItem]) {
        self.mapItems = mapItems
    }
    
    /**
        Sets whether or not editing is enabled.
    
        :param: enabled `true` if editing is enabled; `false` otherwise.
    */
    func setEditingEnabled(enabled: Bool) {
        editingEnabled = enabled
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
    
    // MARK: - Methods for segueing.
    
    /**
        When locations table view is about to be created, set map view and load initial map items.
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let identifier = segue.identifier {
            if identifier == locationsTableViewSegue {
                let locationsTableViewController = segue.destinationViewController as! LocationsTableViewController
                
                // Set map, map items, and editing enabled for table view controller.
                locationsTableViewController.setMapView(mapView)
                if let mapItems = mapItems {
                    locationsTableViewController.loadData(mapItems)
                }
                if let editingEnabled = editingEnabled {
                    locationsTableViewController.setEditingEnabled(editingEnabled)
                }
            }
        }
    }
    
    /**
        Checks if the user location is accessible. If not, display an alert.
    */
    func checkLocationAccessibility() {
        if isViewLoaded() && view?.window != nil && !locationAccessible() {
            displayLocationInaccessibleAlert()
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