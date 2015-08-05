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
        
        NSNotificationCenter.defaultCenter().postNotificationName("MapViewLoaded", object: self, userInfo: ["MapView": mapView])
        
        /*
        var annotation = MKPointAnnotation()
        annotation.coordinate = item.placemark.coordinate
        annotation.title = item.name
        self.mapView.addAnnotation(annotation)
        */
    }
    
    /**
        Centers the map on the specified location with the given region radius.
    
        :param: location The location to center the map on.
        :param: regionRadius The radius of the region to display around `location`. Default is 1000m.
    */
    func centerMap(location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        mapView.showsUserLocation = true
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - MKMapViewDelegate
extension LocationsMapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        centerMap(userLocation.location)
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationsMapViewController: CLLocationManagerDelegate {
    /**
        When locations are updated, center the map.
    */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        centerMap(manager.location)
    }
    
    /**
        On error, show description of error.
    */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("%@", error.localizedDescription)
    }
}
