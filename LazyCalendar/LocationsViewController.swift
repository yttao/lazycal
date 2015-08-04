//
//  LocationsViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/3/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import MapKit

class LocationsViewController: UIViewController {
    @IBOutlet weak var locationsMapViewContainer: UIView!
    @IBOutlet weak var locationsTableViewContainer: UIView!
    
    private let locationManager = CLLocationManager()
    
    private var mapView: MKMapView?
    
    private let locationsTableViewSegue = "LocationsTableViewSegue"
    private let locationsMapViewSegue = "LocationsMapViewSegue"
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setMapView:", name: "MapViewLoaded", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeHeightConstraints()
        
        checkLocationAuthorizationStatus()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /**
        Initialize height constraints on the map view. The height constraints are determined by device size while the table view container takes up the remaining space.
    
        The map's height is 1/3 of the screen.
    */
    func initializeHeightConstraints() {
        let heightConstraint = NSLayoutConstraint(item: locationsMapViewContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: view.frame.height / 3)
        locationsMapViewContainer.addConstraint(heightConstraint)
    }
    
    func checkLocationAuthorizationStatus() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if authorizationStatus == .AuthorizedWhenInUse {
            NSNotificationCenter.defaultCenter().postNotificationName("LocationUseAuthorized", object: self, userInfo: nil)
        }
    }
    
    func setMapView(notification: NSNotification) {
        mapView = notification.userInfo!["MapView"] as? MKMapView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let identifier = segue.identifier {
            if identifier == locationsTableViewSegue {
                let locationsTableViewController = segue.destinationViewController as! LocationsTableViewController
                locationsTableViewController.setMapView(mapView)
            }
        }
    }
}
