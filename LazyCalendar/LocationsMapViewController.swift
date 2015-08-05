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

    // Radius in meters
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
        
        /*
        var annotation = MKPointAnnotation()
        annotation.coordinate = item.placemark.coordinate
        annotation.title = item.name
        self.mapView.addAnnotation(annotation)
        */
    }
    
    /**
        Centers the map on the user's location.
    */
    func centerOnUserLocation() {
        mapView.showsUserLocation = true
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        println("Center: \(mapView.region.center.latitude), \(mapView.region.center.longitude)")
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
