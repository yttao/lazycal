//
//  LZEvent.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/19/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import AddressBook
import CoreData
import CoreLocation

class LZEvent: NSManagedObject, Equatable {
    // MARK: - Constants
    private static let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    private static let entity = NSEntityDescription.entityForName("LZEvent", inManagedObjectContext: LZEvent.managedContext)!
    
    // MARK - Persistent storage properties
    
    @NSManaged var id: String
    
    @NSManaged var name: String?
    
    @NSManaged var dateStart: NSDate
    @NSManaged var dateEnd: NSDate
    
    @NSManaged var alarm: Bool
    @NSManaged var alarmTime: NSDate?
    
    @NSManaged var contacts: NSSet
    @NSManaged var locations: NSSet
    
    // MARK: - Computed properties
    
    var storedContacts: NSMutableSet {
        return mutableSetValueForKey("contacts")
    }
    var storedLocations: NSMutableSet {
        return mutableSetValueForKey("locations")
    }
    
    // MARK: - Initializers
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init() {
        super.init(entity: LZEvent.entity, insertIntoManagedObjectContext: LZEvent.managedContext)
        
        id = NSUUID().UUIDString
    }
    
    /**
        Initializes the event with an id.
    
        :param: id The unique id of the event.
    */
    init(id: String) {
        super.init(entity: LZEvent.entity, insertIntoManagedObjectContext: LZEvent.managedContext)
        
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
        super.init(entity: LZEvent.entity, insertIntoManagedObjectContext: LZEvent.managedContext)
        
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
    
    /**
        Adds a location to the event.
    
        :param: location The location to add.
    */
    func addLocation(location: LZLocation) {
        storedLocations.addObject(location)
        addRelationship(location)
    }
    
    /**
        Removes a location from the event.
    
        :param: location The location to remove.
    */
    func removeLocation(location: LZLocation) {
        storedLocations.removeObject(location)
        removeRelationship(location)
    }
    
    /**
        Adds a contact to the event.
    
        :param: contact The contact to add.
    */
    func addContact(contact: LZContact) {
        storedContacts.addObject(contact)
        addRelationship(contact)
    }
    
    /**
        Removes a contact from the event.
    
        :param: contact The contact to remove.
    */
    func removeContact(contact: LZContact) {
        storedContacts.removeObject(contact)
        removeRelationship(contact)
    }
    
    /**
        Adds the event to its relationship with another object.
    
        :param: relatedObject The object that is related to the event.
    */
    func addRelationship(relatedObject: NSManagedObject) {
        let inverse = relatedObject.mutableSetValueForKey("events")
        inverse.addObject(self)
    }
    
    /**
        Removes the event from its relationship with another object. It then checks if the relationship still has associated events. If not, the object is no longer needed and the object is removed from persistent storage.
    
        :param: relatedObject The object that was related to the event.
    */
    func removeRelationship(relatedObject: NSManagedObject) {
        let inverse = relatedObject.mutableSetValueForKey("events")
        inverse.removeObject(self)
        
        // Remove object if it has no associated events.
        if inverse.count == 0 {
            LZEvent.managedContext.deleteObject(relatedObject)
        }
    }
}

// MARK: - Equatable

/**
    Two `LZEvents` are equal if their `id` properties match.

    :param: lhs The first `LZEvent`.
    :param: rhs The second `LZEvent`.
    :returns: `true` if the `LZEvents` have the same `id` properties; `false` otherwise.
*/
func ==(lhs: LZEvent, rhs: LZEvent) -> Bool {
    return lhs.id == rhs.id
}
