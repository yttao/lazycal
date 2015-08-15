//
//  MapItem.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/10/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import MapKit
import AddressBookUI

class MapItem: NSObject, MKAnnotation, Equatable, Hashable {
    var coordinate: CLLocationCoordinate2D
    var name: String?
    var address: String?
    var addressDictionary: [NSObject: AnyObject]?
    var title: String? {
        return name
    }
    var subtitle: String? {
        return address
    }
    var location: CLLocation {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    var additionalInfo: [NSObject: AnyObject]?
    
    /**
        Initializes this instance with a `Location` object.
    
        :param: location The `Location` corresponding to the `MapItem.
    */
    init(location: Location) {
        coordinate = location.coordinate
        name = location.name
        address = location.address
        super.init()
    }
    
    init(coordinate: CLLocationCoordinate2D, name: String?, addressDictionary: [NSObject: AnyObject]) {
        self.coordinate = coordinate
        self.name = name
        self.addressDictionary = addressDictionary
        self.address = MapItem.stringFromAddressDictionary(addressDictionary)
        super.init()
    }
    
    /**
        Initializes this instance with coordinate, name, and address.
    
        :param: coordinate The coordinate of the item.
        
        :param: name The name of the item. This is the title of the annotation.
    
        :param: address The address of the item. This is the subtitle of the annotation.
    */
    init(coordinate: CLLocationCoordinate2D, name: String?, address: String?) {
        self.coordinate = coordinate
        self.name = name
        self.address = address
        super.init()
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
    */
    static func stringFromAddressDictionary(addressDictionary: [NSObject: AnyObject]) -> String {
        return ABCreateStringWithAddressDictionary(addressDictionary, false).stringByReplacingOccurrencesOfString("\n", withString: " ")
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
    Two `MapItem` instances are considered equal if they share the same names, addresses, and coordinates.
*/
func ==(lhs: MapItem, rhs: MapItem) -> Bool {
    let nameMatch = lhs.name == rhs.name
    let addressMatch = lhs.address == rhs.address
    
    // Floating point comparisons
    let latitudeMatch = fabs(lhs.coordinate.latitude - rhs.coordinate.latitude) < Math.epsilon
    let longitudeMatch = fabs(lhs.coordinate.longitude - rhs.coordinate.longitude) < Math.epsilon
    let coordinateMatch = latitudeMatch && longitudeMatch
    return coordinateMatch && nameMatch && addressMatch
}