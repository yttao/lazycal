//
//  Models.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/24/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import AddressBook
import CoreData
import CoreLocation

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
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init() {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let entity = NSEntityDescription.entityForName("FullEvent", inManagedObjectContext: managedContext)!
        super.init(entity: entity, insertIntoManagedObjectContext: managedContext)
        
        self.id = NSUUID().UUIDString
    }
    
    // MARK: - Initializers

    /**
        Initializes the event with an id.
    
        :param: id The unique id of the event.
    */
    init(id: String) {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let entity = NSEntityDescription.entityForName("FullEvent", inManagedObjectContext: managedContext)!
        super.init(entity: entity, insertIntoManagedObjectContext: managedContext)
        
        self.id = id
    }
    
    /**
        Initializes the event with given arguments.
    
        :param: id The unique id of the event.
        :param: name The name of the event.
        :param: dateStart The start date of the event.
        :param: dateEnd The end date of the event.
        :param: alarm A `Bool` indicating whether the event has an alarm.
        :param: alarmTime The time that the alarm will fire if `alarm == true`. If `alarm == false`, the `FullEvent`'s `alarmTime` property will be set to `nil` even if a non-`nil` argument is passed in.
    */
    init(id: String, name: String?, dateStart: NSDate, dateEnd: NSDate, alarm: Bool, alarmTime: NSDate?) {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let entity = NSEntityDescription.entityForName("FullEvent", inManagedObjectContext: managedContext)!
        super.init(entity: entity, insertIntoManagedObjectContext: managedContext)
        
        self.id = id
        self.name = name
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.alarm = alarm
        if alarm {
            self.alarmTime = alarmTime
        }
        else {
            self.alarmTime = nil
        }
    }
    
    func removeRelation(relatedObject: NSManagedObject) {
        let storedEvents = relatedObject.mutableSetValueForKey("events")
        storedEvents.removeObject(self)
        
        if storedEvents.count == 0 {
            let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
            managedContext.deleteObject(relatedObject)
        }
    }
}

class Contact: NSManagedObject, Equatable {
    @NSManaged var id: Int32
    
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    
    @NSManaged var events: NSSet
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
        Initializes the contact with given arguments.
    
        :param: id The contact ID.
        :param: firstName The contact's first name.
        :param: lastName The contact's last name.
    */
    init(id: ABRecordID, firstName: String?, lastName: String?) {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let entity = NSEntityDescription.entityForName("Contact", inManagedObjectContext: managedContext)!
        super.init(entity: entity, insertIntoManagedObjectContext: managedContext)
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
}

class Location: NSManagedObject, Equatable {
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    
    @NSManaged var name: String?
    @NSManaged var address: String?
    
    @NSManaged var events: NSSet
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(latitude, longitude)
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
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
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedContext)!
        super.init(entity: entity, insertIntoManagedObjectContext: managedContext)
        
        self.coordinate = coordinate
        self.name = name
        self.address = address
    }
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
    let latitudeMatch = fabs(lhs.latitude - rhs.latitude) < Math.epsilon
    let longitudeMatch = fabs(lhs.longitude - rhs.longitude) < Math.epsilon
    let coordinateMatch = latitudeMatch && longitudeMatch
    
    let nameMatch = lhs.name == rhs.name
    let addressMatch = lhs.address == rhs.address
    return coordinateMatch && nameMatch && addressMatch
}