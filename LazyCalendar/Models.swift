//
//  Models.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/24/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Classes

class FullEvent: NSManagedObject, Equatable {
    @NSManaged var id: String
    
    @NSManaged var name: String?
    
    @NSManaged var dateStart: NSDate
    @NSManaged var dateEnd: NSDate
    
    @NSManaged var alarm: Bool
    @NSManaged var alarmTime: NSDate?
    
    @NSManaged var contacts: NSSet
    @NSManaged var locations: NSSet
}

class Contact: NSManagedObject, Equatable {
    @NSManaged var id: Int32
    
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    
    @NSManaged var events: NSSet
}

class Location: NSManagedObject, Equatable {
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    
    @NSManaged var name: String?
    @NSManaged var address: String?
    
    @NSManaged var events: NSSet
}

// MARK: - Equatable

/**
    Two `FullEvents` are equal if their `id` properties match.

    :param: lhs The first `FullEvent`.
    :param: rhs The second `FullEvent`.
    :returns: `true` if the `FullEvents` have the same `id` properties; `false` otherwise.
*/
func ==(lhs: FullEvent, rhs: FullEvent) -> Bool {
    return lhs.id == rhs.id
}

/**
    Two `Contacts` are equal if their id's, first names, and last names match.

    :param: lhs The first `Contact`.
    :param: rhs The second `Contact`.
    :returns: `true` if the `Contacts` have the same `id`, `firstName` , and `lastName` properties; `false` otherwise.
*/
func ==(lhs: Contact, rhs: Contact) -> Bool {
    let idMatch = lhs.id == rhs.id
    let nameMatch = lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName
    return idMatch && nameMatch
}

/**
    Two `Locations` are equal if their `name`, `address`, and coordinates (`latitude` and `longitude`) properties match.

    :param: lhs The first `Location`.
    :param: rhs The second `Location`.
    :returns: `true` if the `Locations` have the same `name`, `address`, and coordinates (`latitude` and `longitude`) properties match; `false` otherwise.
*/
func ==(lhs: Location, rhs: Location) -> Bool {
    let EPSILON = pow(10.0, -10.0)
    let latitudeMatch = fabs(lhs.latitude - rhs.latitude) < EPSILON
    let longitudeMatch = fabs(lhs.longitude - rhs.longitude) < EPSILON
    let coordinateMatch = latitudeMatch && longitudeMatch
    
    let nameMatch = lhs.name == rhs.name
    let addressMatch = lhs.address == rhs.address
    return coordinateMatch && nameMatch && addressMatch
}