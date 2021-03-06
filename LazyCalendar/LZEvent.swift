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
    @NSManaged var dateStartTimeZoneName: String
    
    @NSManaged var dateEnd: NSDate
    @NSManaged var dateEndTimeZoneName: String
    
    @NSManaged var alarm: Bool
    @NSManaged var alarmTime: NSDate?
    
    @NSManaged var weather: Bool
    
    @NSManaged var contacts: NSOrderedSet
    @NSManaged var locations: NSOrderedSet
    
    // MARK: - Computed properties
    
    var dateStartTimeZone: NSTimeZone {
        get {
            return NSTimeZone(name: dateStartTimeZoneName)!
        }
        set {
            dateStartTimeZoneName = newValue.name
        }
        
    }
    var dateEndTimeZone: NSTimeZone {
        get {
            return NSTimeZone(name: dateEndTimeZoneName)!
        }
        set {
            dateEndTimeZoneName = newValue.name
        }
        
    }
    
    var storedContacts: NSMutableOrderedSet {
        return mutableOrderedSetValueForKey("contacts")
    }
    var storedLocations: NSMutableOrderedSet {
        return mutableOrderedSetValueForKey("locations")
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
        :param: alarmTime The time that the alarm will fire if `alarm == true`. If `alarm == false`, the `LZEvent`'s `alarmTime` property will be set to `nil` even if a non-`nil` argument is passed in.
    */
    init(id: String, name: String?, dateStart: NSDate, dateStartTimeZone: NSTimeZone, dateEnd: NSDate, dateEndTimeZone: NSTimeZone, alarm: Bool, alarmTime: NSDate?) {
        super.init(entity: LZEvent.entity, insertIntoManagedObjectContext: LZEvent.managedContext)
        
        self.id = id
        self.name = name
        self.dateStart = dateStart
        self.dateStartTimeZone = dateStartTimeZone
        self.dateEnd = dateEnd
        self.dateEndTimeZone = dateEndTimeZone
        self.alarm = alarm
        if alarm {
            self.alarmTime = alarmTime
        }
        else {
            self.alarmTime = nil
        }
    }
    
    // MARK: - Methods for adding and removing relations.
    
    /**
        Adds a location to the event.
    
        :param: location The location to add.
    */
    func addLocation(location: LZLocation) {
        storedLocations.addObject(location)
        addRelation(location)
    }
    
    /**
        Removes a location from the event.
    
        :param: location The location to remove.
    */
    func removeLocation(location: LZLocation) {
        storedLocations.removeObject(location)
        removeRelation(location)
    }
    
    /**
        Adds a contact to the event.
    
        :param: contact The contact to add.
    */
    func addContact(contact: LZContact) {
        storedContacts.addObject(contact)
        addRelation(contact)
    }
    
    /**
        Removes a contact from the event.
    
        :param: contact The contact to remove.
    */
    func removeContact(contact: LZContact) {
        storedContacts.removeObject(contact)
        removeRelation(contact)
    }
    
    /**
        Adds the event to its relationship with another object.
    
        :param: relatedObject The object that is associated with the event.
    */
    func addRelation(relatedObject: NSManagedObject) {
        let inverse = relatedObject.mutableSetValueForKey("events")
        inverse.addObject(self)
    }
    
    /**
        Removes the event from its relationship with another object. It then checks if the relationship still has associated events. If not, the object is no longer needed and the object is removed from persistent storage.
    
        :param: relatedObject The object that was associated with the event.
        :param: withDeletion If `true`, deletes the object if it has no associated events. Default is `true`.
    */
    func removeRelation(relatedObject: NSManagedObject, withDeletion: Bool = true) {
        let inverse = relatedObject.mutableSetValueForKey("events")
        inverse.removeObject(self)
        
        // Remove object if it has no associated events.
        if withDeletion && inverse.count == 0 {
            LZEvent.managedContext.deleteObject(relatedObject)
        }
    }
    
    /**
        Gets the events that fall within a range of dates.
    
        :param: lowerDate The earlier date.
        :param: upperDate The later date.
        :returns: An array containing the events within
    */
    static func getStoredEvents(#lowerDate: NSDate, upperDate: NSDate) -> [LZEvent] {
        // Create fetch request for data
        let fetchRequest = NSFetchRequest(entityName: "LZEvent")
        
        // To show an event, the time interval from dateStart to dateEnd must fall between lowerDate and upperDate.
        // (dateStart >= lower && dateStart < upper) || (dateEnd >= lower && dateEnd < upper) || (dateStart < lower && dateEnd >= lower) || (dateStart < upper && dateEnd >= upper)
        let requirements = "(dateStart >= %@ AND dateStart < %@) OR (dateEnd >= %@ AND dateEnd < %@) OR (dateStart <= %@ AND dateEnd >= %@) OR (dateStart <= %@ AND dateEnd >= %@)"
        let predicate = NSPredicate(format: requirements, lowerDate, upperDate, lowerDate, upperDate, lowerDate, lowerDate, upperDate, upperDate)
        fetchRequest.predicate = predicate
        
        // Execute fetch request
        var error: NSError? = nil
        let storedEvents = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [LZEvent]
        
        return storedEvents
    }
    
    /**
        Returns `true` if the the contact's address has been included in the event's locations. Otherwise returns `false`.
    
        :param: contact The contact to check.
        :returns: `true` if the contact has been selected for the event's locations; `false` otherwise.
    */
    func contactSelectedInLocations(contact: LZContact) -> Bool {
        let contactLocations = contact.storedLocations.allObjects as! [LZLocation]
        let eventLocations = storedLocations.array as! [LZLocation]
        for contactLocation in contactLocations {
            if contains(eventLocations, contactLocation) {
                return true
            }
        }
        return false
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
