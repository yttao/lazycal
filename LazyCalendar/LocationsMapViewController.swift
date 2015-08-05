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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            centerOnUserLocation()
        }
        locationManager.stopUpdatingLocation()
        
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
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        println("Center: \(mapView.region.center.latitude), \(mapView.region.center.longitude)")
        println("\(locationManager.location.coordinate.latitude), \(locationManager.location.coordinate.longitude)")
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension LocationsMapViewController: MKMapViewDelegate {
    /**
        If the user location changes, update the center coordinate.
    */
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        mapView.centerCoordinate = mapView.userLocation.location.coordinate
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationsMapViewController: CLLocationManagerDelegate {
}
