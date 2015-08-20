//
//  LZLocation.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/19/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import AddressBook
import CoreData
import MapKit

class LZLocation: NSManagedObject, Equatable, MKAnnotation {
    // MARK: - Constants
    private static let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    private static let entity = NSEntityDescription.entityForName("LZLocation", inManagedObjectContext: LZLocation.managedContext)!

    // MARK: - Persistent storage properties
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    
    @NSManaged var name: String?
    @NSManaged var address: String?
    
    @NSManaged var events: NSSet
    
    // MARK: - Non-stored/computed properties.
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(latitude, longitude)
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    var addressDictionary: [NSObject: AnyObject]?
    
    var location: CLLocation {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    var additionalInfo: [NSObject: AnyObject]?
    
    var storedEvents: NSMutableSet {
        return mutableSetValueForKey("events")
    }
    
    // MARK: - MKAnnotation properties
    
    var title: String? {
        return name
    }
    var subtitle: String? {
        return address
    }
    
    // MARK: - Initializers
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
        Initializes the location with given arguments.
    
        :param: coordinate The coordinate of the location.
        :param: name The name of the location.
        :param: address The address of the location.
    */
    init(coordinate: CLLocationCoordinate2D, name: String?, address: String?) {
        super.init(entity: LZLocation.entity, insertIntoManagedObjectContext: LZLocation.managedContext)
        
        self.coordinate = coordinate
        self.name = name
        self.address = address
    }
    
    init(mapItem: MapItem) {
        super.init(entity: LZLocation.entity, insertIntoManagedObjectContext: LZLocation.managedContext)
        
        coordinate = mapItem.coordinate
        name = mapItem.name
        address = mapItem.address
    }
    
    // MARK: - Search functions
    
    /**
        Searches the stored locations for a given location.
    
        Currently, stored locations are found by matching coordinates.
    
        :param: coordinate The coordinate of the location to be found.
        :returns: The `Location` object if it was found or `nil` if none was found.
    */
    static func getStoredLocation(coordinate: CLLocationCoordinate2D) -> LZLocation? {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        // Create fetch request for a location entity
        let fetchRequest = NSFetchRequest(entityName: "LZLocation")
        fetchRequest.fetchLimit = 1
        
        // A stored location and the map item's location are considered the same if they have the same coordinates (matching latitude and longitude).
        let requirements = "((latitude - %d) < %d AND (latitude - %d) > %d) AND ((longitude - %d) < %d AND (longitude - %d) > %d)"
        let predicate = NSPredicate(format: requirements, argumentArray: [latitude, Math.epsilon, longitude, -Math.epsilon, longitude, Math.epsilon, longitude, -Math.epsilon])
        fetchRequest.predicate = predicate
        
        // Search for location in storage.
        var error: NSError? = nil
        let storedLocation = LZLocation.managedContext.executeFetchRequest(fetchRequest, error: &error)?.first as? LZLocation
        if let error = error {
            NSLog("Error occurred while fetching stored location: %@", error.localizedDescription)
        }
        
        return storedLocation
    }
}

/**
    Two `Locations` are equal if their `name`, `address`, and coordinates (`latitude` and `longitude`) properties match.

    :param: lhs The first `Location`.
    :param: rhs The second `Location`.
    :returns: `true` if the `Locations` have the same `name`, `address`, and coordinates (`latitude` and `longitude`) properties match; `false` otherwise.
*/
func ==(lhs: LZLocation, rhs: LZLocation) -> Bool {
    let latitudeMatch = fabs(lhs.latitude - rhs.latitude) < Math.epsilon
    let longitudeMatch = fabs(lhs.longitude - rhs.longitude) < Math.epsilon
    let coordinateMatch = latitudeMatch && longitudeMatch
    
    let nameMatch = lhs.name == rhs.name
    let addressMatch = lhs.address == rhs.address
    return coordinateMatch && nameMatch && addressMatch
}
