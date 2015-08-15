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
import QuartzCore

class LocationsMapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapButton: UIButton!
    
    private let locationManager = CLLocationManager()
    
    // The current directions
    private var directions: MKDirections?
    // The currently displayed route
    private var route: MKRoute?
    
    // MARK: - Methods for initializing view controller and data.
    
    /**
        Attach observer for when location use is authorized.
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectLocation:", name: "LocationSelected", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
        mapButton.addTarget(self, action: "showMapOptions", forControlEvents: .TouchDown)
        mapView.addSubview(mapButton)
        mapView.didAddSubview(mapButton)
            
        NSNotificationCenter.defaultCenter().postNotificationName("MapViewLoaded", object: self, userInfo: ["MapView": mapView])
    }
    
    // MARK: - Methods for controlling map view.
    
    /**
        Centers the map on the location and draws the directions to that location upon notification.
    
        :param: notification The notification that a location has been selected.
    */
    func selectLocation(notification: NSNotification) {
        let location = notification.userInfo!["Location"] as! CLLocation
        centerMap(location)
        
        // Cancel old directions calculation.
        directions?.cancel()
        directions = notification.userInfo!["Directions"] as? MKDirections
        drawDirections(directions!)
    }
    
    /**
        Centers the map on the specified location with the given region radius.
    
        :param: location The location to center the map on.
        :param: regionRadius The radius of the region to display around `location`. Default is 1000m.
    */
    private func centerMap(location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        mapView.showsUserLocation = true
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    /**
        Draws the directions from the current location to a location upon notification.
    
        :param: notification The notification that the directions should be drawn.
    */
    func drawDirections(directions: MKDirections) {
        // Calculate directions.
        directions.calculateDirectionsWithCompletionHandler({
            (response: MKDirectionsResponse?, error: NSError?) in
            if let error = error {
                // Display error if there is one.
                NSLog("Error occurred when calculating directions: %@", error.localizedDescription)
            }
            else if let response = response, newRoutes = response.routes as? [MKRoute] {
                // Get routes
                for newRoute in newRoutes {
                    // Erase old route
                    if let oldRoute = self.route {
                        self.mapView.removeOverlay(oldRoute.polyline)
                    }
                    
                    // Draw new route
                    self.mapView.addOverlay(newRoute.polyline, level: .AboveRoads)
                    self.route = newRoute
                    
                    let steps = self.route!.steps as! [MKRouteStep]
                    for step in steps {
                        println(step.instructions)
                    }
                }
            }
        })
    }
    
    // MARK: - Methods related to controlling the map button.
    
    /**
        When the map button is selected, show more options.
    */
    func showMapOptions() {
        mapButton.hidden = true
        
        let mapSegmentedControl = UISegmentedControl()
        mapSegmentedControl.setTranslatesAutoresizingMaskIntoConstraints(false)
        mapSegmentedControl.insertSegmentWithTitle("First", atIndex: 0, animated: false)
        mapSegmentedControl.insertSegmentWithTitle("Second", atIndex: 1, animated: false)
        mapSegmentedControl.sizeToFit()
        
        // Add animation for appearance
        let animation = CATransition()
        animation.duration = 0.1
        animation.type = kCATransitionMoveIn
        animation.subtype = kCATransitionFromRight
        mapSegmentedControl.layer.addAnimation(animation, forKey: nil)
        
        mapView.addSubview(mapSegmentedControl)
        mapView.didAddSubview(mapSegmentedControl)
        
        let trailingConstraint = NSLayoutConstraint(item: mapSegmentedControl, attribute: .Trailing, relatedBy: .Equal, toItem: mapView, attribute: .Trailing, multiplier: 1, constant: -8)
        let bottomConstraint = NSLayoutConstraint(item: mapSegmentedControl, attribute: .Bottom, relatedBy: .Equal, toItem: mapView, attribute: .Bottom, multiplier: 1, constant: -8)
        let heightConstraint = NSLayoutConstraint(item: mapSegmentedControl, attribute: .Height, relatedBy: .Equal, toItem: mapButton, attribute: .Height, multiplier: 1, constant: 0)
        
        mapView.addConstraint(trailingConstraint)
        mapView.addConstraint(bottomConstraint)
        mapView.addConstraint(heightConstraint)
    }
}

// MARK: - MKMapViewDelegate
extension LocationsMapViewController: MKMapViewDelegate {
    /**
        Renders the navigation directions overlay line.
    */
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blueColor()
            renderer.lineWidth = 5
            return renderer
        }
        return nil
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationsMapViewController: CLLocationManagerDelegate {
    /**
        When locations are updated, center the map.
    */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        centerMap(manager.location)
        locationManager.stopUpdatingLocation()
    }
    
    /**
        On error, show description of error.
    */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("Error occurred with location manager: %@", error.localizedDescription)
    }
}
