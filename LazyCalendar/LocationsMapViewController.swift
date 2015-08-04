//
//  LocationsMapViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/3/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import MapKit
import AddressBook
import CoreLocation

class LocationsMapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!

    // Radius in kilometers
    private let regionRadius: CLLocationDistance = 1000
    
    private let locationManager = CLLocationManager()
    
    /**
        Attach observer for when location use is authorized.
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "centerOnUserLocation", name: "LocationUseAuthorized", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
            centerOnUserLocation()
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("MapViewLoaded", object: self, userInfo: ["MapView": mapView])
    }
    
    /**
        Centers the map on the user's location.
    */
    func centerOnUserLocation() {
        println("centering on \(mapView.userLocation.coordinate)")
        mapView.showsUserLocation = true
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
