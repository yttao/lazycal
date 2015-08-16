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
    private let mapSegmentedControl = MultipleSelectionSegmentedControl()

    // Segments of map segmented control (in order).
    private let controlSegments = ["Less", "Navigate", "Directions"]
    
    // True if navigate segment is enabled.
    private var navigateEnabled: Bool {
        return mapSegmentedControl.selectedSegment(1)
    }
    // True if directions segment is enabled.
    private var directionsEnabled: Bool {
        return mapSegmentedControl.selectedSegment(2)
    }
    
    // The current directions
    private var directions: MKDirections?
    // The currently displayed route
    private var route: MKRoute?
    
    private var selectedMapItem: MapItem? {
        let annotation = mapView.selectedAnnotations?.first as? MapItem
        if let annotation = annotation {
            return annotation
        }
        return nil
    }
    
    // MARK: - Methods for initializing view controller and data.
    
    /**
        Attach observer for when location use is authorized.
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectMapItem:", name: "MapItemSelected", object: nil)
    }
    
    /**
        Set up delegates, start tracking location, set up buttons, and send notification that map view is loaded.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
        setupMapButton()
        setupMapSegmentedControl()
        
        NSNotificationCenter.defaultCenter().postNotificationName("MapViewLoaded", object: self, userInfo: ["MapView": mapView])
    }
    
    /**
        Sets up the map button.
    
        Adds the map button as a subview of the map view and sets `showMapOptions` as a selector when the map button is touched.
    */
    private func setupMapButton() {
        // Add subview.
        mapView.addSubview(mapButton)
        mapView.didAddSubview(mapButton)
        
        // Add target.
        mapButton.addTarget(self, action: "showMapOptions", forControlEvents: .TouchDown)
    }
    
    /**
        Sets up the map segmented control.
    
        Sets up the segments, adds the map segmented control as a subview of the map view, sets up constraints for positioning, sets `toggleMapOption` as a selector when a map button is touched, and hides map segmented control.
    */
    private func setupMapSegmentedControl() {
        // Set up segments.
        for (index, title) in enumerate(controlSegments) {
            mapSegmentedControl.insertSegmentWithTitle(title, atIndex: index, animated: false)
        }
        mapSegmentedControl.sizeToFit()
        
        // Add subview.
        mapView.addSubview(mapSegmentedControl)
        mapView.didAddSubview(mapSegmentedControl)
        
        // Set up constraints.
        mapSegmentedControl.setTranslatesAutoresizingMaskIntoConstraints(false)
        let trailingConstraint = NSLayoutConstraint(item: mapSegmentedControl, attribute: .Trailing, relatedBy: .Equal, toItem: mapSegmentedControl.superview, attribute: .Trailing, multiplier: 1, constant: -8)
        let bottomConstraint = NSLayoutConstraint(item: mapSegmentedControl, attribute: .Bottom, relatedBy: .Equal, toItem: mapSegmentedControl.superview, attribute: .Bottom, multiplier: 1, constant: -8)
        mapView.addConstraint(trailingConstraint)
        mapView.addConstraint(bottomConstraint)
        
        // Add target.
        mapSegmentedControl.addTarget(self, action: "toggleMapOption", forControlEvents: .ValueChanged)
        
        // Hide segmented control.
        mapSegmentedControl.hidden = true
    }
    
    // MARK: - Methods for controlling map view.
    
    /**
        Centers the map on the location and draws the directions to that location upon notification.
    
        :param: notification The notification that a location has been selected.
    */
    func selectMapItem(notification: NSNotification) {
        let mapItem = notification.userInfo!["MapItem"] as! MapItem
        
        // Center map on location.
        centerMap(mapItem.location)
        
        mapView.selectAnnotation(mapItem, animated: true)
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
        Calculates the directions and shows them if navigation is enabled.
    
        Calculate the directions and draw the directions on the map view.
    */
    func calculateDirections() {
        // Calculate directions.
        directions?.calculateDirectionsWithCompletionHandler({
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
                    
                    // Set new route.
                    self.route = newRoute
                    
                    if self.navigateEnabled {
                        self.showRoute()
                    }
                    else {
                        self.hideRoute()
                    }
                    
                    let steps = self.route!.steps as! [MKRouteStep]
                    for step in steps {
                        println(step.instructions)
                    }
                }
            }
        })
    }
    
    /**
        Shows the navigation route on the map. If there is no route to draw on the map, this method does nothing.
    */
    func showRoute() {
        if let route = route {
            mapView.addOverlay(route.polyline, level: .AboveRoads)
        }
    }
    
    /**
        Hides the navigation route on the map. If there is no route drawn on the map, this method does nothing.
    */
    func hideRoute() {
        if let route = route {
            mapView.removeOverlay(route.polyline)
        }
    }
    
    // MARK: - Methods related to controlling the map button.
    
    /**
        When the map button is selected, show more options.
    */
    func showMapOptions() {
        // Add animation for appearance.
        let animation = CATransition()
        animation.duration = 0.1
        animation.type = kCATransitionMoveIn
        animation.subtype = kCATransitionFromRight
        mapSegmentedControl.layer.addAnimation(animation, forKey: "Show")
        
        mapButton.hidden = true
        mapSegmentedControl.hidden = false
    }
    
    // MARK: - Methods related to controlling the map segmented control.
    
    /**
        When the map segmented control "Less" button is selected, hide options.
    */
    func hideMapOptions() {
        mapSegmentedControl.deselectAllSegments()
        
        // Add animation for hiding.
        let animation = CATransition()
        animation.duration = 0.1
        animation.type = kCATransitionMoveIn
        animation.subtype = kCATransitionFromRight
        mapSegmentedControl.layer.addAnimation(animation, forKey: "Hide")
        
        mapSegmentedControl.hidden = true
        mapButton.hidden = false
    }
    
    /**
        Toggles the map option that was just touched on the map segmented control.
    */
    func toggleMapOption() {
        // Get segment index that was just toggled.
        if let toggledSegmentIndex = mapSegmentedControl.toggledIndex {
            // Take action based on toggled segment.
            
            if toggledSegmentIndex == 0 {
                hideMapOptions()
            }
            else if toggledSegmentIndex == 1 {
                if mapSegmentedControl.selectedSegment(toggledSegmentIndex) && selectedMapItem != nil {
                    calculateDirections()
                }
                else if !mapSegmentedControl.selectedSegment(toggledSegmentIndex) {
                    hideRoute()
                }
            }
            else if toggledSegmentIndex == 2 && mapSegmentedControl.selectedSegment(toggledSegmentIndex) && selectedMapItem != nil {
            }
        }
    }
    
    /**
        Updates the current set of directions. If no map item is currently selected, the directions are `nil`.
    */
    func updateDirections() {
        directions?.cancel()
        if let selectedMapItem = selectedMapItem {
            directions = getDirections(fromLocation: MKMapItem.mapItemForCurrentLocation(), toLocation: selectedMapItem.getMKMapItem())
        }
        else {
            directions = nil
        }
    }
    
    // MARK: - Methods for navigation.
    
    /**
        Gets a set of directions from one place to another.
    
        :param: source The start location.
        :param: destination The end location.
        :returns: The directions from the first location to the second location.
    */
    func getDirections(fromLocation source: MKMapItem, toLocation destination: MKMapItem) -> MKDirections {
        let request = MKDirectionsRequest()
        request.setSource(source)
        request.setDestination(destination)
        request.transportType = .Any
        return MKDirections(request: request)
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
            renderer.lineWidth = 3
            return renderer
        }
        return nil
    }
    
    /**
        When the annotation view is selected and the segmented control is currently on "Navigation", draw directions to the annotation.
    */
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        updateDirections()
        calculateDirections()
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
