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
import AddressBookUI

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
    
    init(coordinate: CLLocationCoordinate2D, name: String?, addressDictionary: [NSObject: AnyObject]) {
        super.init(entity: LZLocation.entity, insertIntoManagedObjectContext: LZLocation.managedContext)
        self.coordinate = coordinate
        self.name = name
        self.addressDictionary = addressDictionary
        self.address = LZLocation.stringFromAddressDictionary(addressDictionary)
        
    }
    
    init(mkMapItem: MKMapItem) {
        super.init(entity: LZLocation.entity, insertIntoManagedObjectContext: LZLocation.managedContext)
        coordinate = mkMapItem.placemark.coordinate
        name = mkMapItem.name
        addressDictionary = mkMapItem.placemark.addressDictionary
        self.address = LZLocation.stringFromAddressDictionary(mkMapItem.placemark.addressDictionary)
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
        
        // Execute fetch request for location.
        var error: NSError? = nil
        let storedLocation = LZLocation.managedContext.executeFetchRequest(fetchRequest, error: &error)?.first as? LZLocation
        if let error = error {
            NSLog("Error occurred while fetching stored location: %@", error.localizedDescription)
        }
        
        return storedLocation
    }
    
    // MARK: - Methods for formatting data.
    
    /**
        Makes an address string out of the available information in the address dictionary.
    
        The address string is created in two steps:
    
        * Create a multiline address with all information.
    
        The address string created by `ABCreateStringWithAddressDictionary:` is a multiline address usually created the following format (if any parts of the address are unavailable, they do not appear):
    
        Street address
    
        City State Zip code
    
        Country
    
        * Replace newlines with spaces.
    
        The newlines are then replaced with spaces using `stringByReplacingOccurrencesOfString:withString:` because the `subtitle` property of `MKAnnotation` can only display single line strings.
    
        :param: addressDictionary A dictionary of address information.
        :returns: The address dictionary in string form. If the address is an empty string, this returns nil.
    */
    static func stringFromAddressDictionary(addressDictionary: [NSObject: AnyObject]) -> String? {
        let address = ABCreateStringWithAddressDictionary(addressDictionary, false).stringByReplacingOccurrencesOfString("\n", withString: ", ")
        if address != "" {
            return address
        }
        return nil
    }
    
    /**
        Converts a `MapItem` into an `MKMapItem`.
    
        If an address dictionary is available, the `MKMapItem` will be returned with an address. Otherwise it has only coordinates.
    */
    func getMKMapItem() -> MKMapItem {
        let placemark: MKPlacemark
        if let addressDictionary = addressDictionary {
            placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        }
        else {
            placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        }
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        return mapItem
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
