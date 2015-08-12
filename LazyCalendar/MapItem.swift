//
//  MapItem.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/10/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import Foundation
import MapKit

class MapItem: NSObject, MKAnnotation, Equatable, Hashable {
    var coordinate: CLLocationCoordinate2D
    var name: String?
    var address: String?
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
}

/**
    Two `MapItem` instances are considered equal if they share the same names, addresses, and coordinates.
*/
func ==(lhs: MapItem, rhs: MapItem) -> Bool {
    let nameMatch = lhs.name == rhs.name
    let addressMatch = lhs.address == rhs.address
    
    // Floating point comparisons
    let EPSILON = pow(10.0, -10.0)
    let latitudeMatch = fabs(lhs.coordinate.latitude - rhs.coordinate.latitude) < EPSILON
    let longitudeMatch = fabs(lhs.coordinate.longitude - rhs.coordinate.longitude) < EPSILON
    let coordinateMatch = latitudeMatch && longitudeMatch
    return coordinateMatch && nameMatch && addressMatch
}