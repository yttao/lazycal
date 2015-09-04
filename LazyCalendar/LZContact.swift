//
//  LZContact.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/19/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import AddressBook
import CoreData
import CoreLocation

class LZContact: NSManagedObject, Equatable {
    // MARK: - Constants
    
    private static let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    private static let entity = NSEntityDescription.entityForName("LZContact", inManagedObjectContext: LZContact.managedContext)!
    
    // MARK: - Persistent storage properties
    
    @NSManaged var id: Int32
    @NSManaged var name: String?
    
    @NSManaged var events: NSSet
    @NSManaged var locations: NSSet
    
    // MARK: - Non-stored/computed properties
    
    var storedEvents: NSMutableSet {
        return mutableSetValueForKey("events")
    }
    
    var storedLocations: NSMutableSet {
        return mutableSetValueForKey("locations")
    }
    
    // MARK: - Initializers
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
        Initializes the contact with given arguments.
    
        :param: id The contact ID.
        :param: firstName The contact's first name.
        :param: lastName The contact's last name.
    */
    init(id: ABRecordID, name: String?) {
        super.init(entity: LZContact.entity, insertIntoManagedObjectContext: LZContact.managedContext)
        
        self.id = id
        self.name = name
    }
    
    // MARK: - Methods for adding and removing relations.
    
    /**
        Adds a location to the contact.
    
        :param: location The location to add.
    */
    func addLocation(location: LZLocation) {
        storedLocations.addObject(location)
        addRelation(location)
    }
    
    /**
        Removes a location from the contact.
    
        :param: location The location to remove.
    */
    func removeLocation(location: LZLocation) {
        storedLocations.removeObject(location)
        removeRelation(location)
    }
    
    /**
        Adds the event to its relationship with another object.
    
        :param: relatedObject The object that is associated with the event.
    */
    func addRelation(relatedObject: NSManagedObject) {
        let inverse = relatedObject.mutableSetValueForKey("contacts")
        inverse.addObject(self)
    }
    
    /**
        Removes the contact from its relationship with another object. It then checks if the relationship still has associated contacts. If not, the object is no longer needed and the object is removed from persistent storage.
    
        :param: relatedObject The object that was associated with the contact.
        :param: withDeletion If `true`, deletes the object if it has no associated contacts. Default is `false`.
    */
    func removeRelation(relatedObject: NSManagedObject, withDeletion: Bool = false) {
        let inverse = relatedObject.mutableSetValueForKey("contacts")
        inverse.removeObject(self)
        
        // Remove object if it has no associated events.
        if withDeletion && inverse.count == 0 {
            LZContact.managedContext.deleteObject(relatedObject)
        }
    }
    
    // MARK: - Search functions
    
    /**
        Searches the stored contacts for a contact. Returns the `Contact` if it was found, or `nil` if none was found.
    
        :param: contactID The ID of the contact to search for.
        :returns: The contact if it was found in storage or `nil` if none was found.
    */
    static func getStoredContact(contactID: ABRecordID) -> LZContact? {
        // Create fetch request for contact
        let fetchRequest = NSFetchRequest(entityName: "LZContact")
        fetchRequest.fetchLimit = 1
        
        // Contact can be found if a stored contact ID matches the given contact ID.
        let requirements = "(id == %d)"
        let predicate = NSPredicate(format: requirements, contactID)
        fetchRequest.predicate = predicate
        
        // Execute fetch request for contact
        var error: NSError? = nil
        let storedContact = LZContact.managedContext.executeFetchRequest(fetchRequest, error: &error)?.first as? LZContact
        if let error = error {
            NSLog("Error occurred while fetching stored contact: %@", error.localizedDescription)
        }
        
        return storedContact
    }
    
    /**
        Returns the `ABRecord` of the person that this `LZContact` is based upon.
    
        :returns: The ABRecord of this contact. If the user has not given access to their address book or no matching record is found, this method returns nil.
    */
    func getABRecordRef() -> ABRecordRef? {
        if let addressBookRef: ABAddressBook? = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue() {
            let recordRef: ABRecordRef? = ABAddressBookGetPersonWithRecordID(addressBookRef, id)?.takeUnretainedValue()
            return recordRef
        }
        NSLog("Attempt to access address book without permission failed.")
        return nil
    }
}

// MARK: - Equatable

/**
    Two `LZContacts` are equal if their id's, first names, and last names match.

    :param: lhs The first `LZContact`.
    :param: rhs The second `LZContact`.
    :returns: `true` if the `LZContacts` have the same `id`, `firstName` , and `lastName` properties; `false` otherwise.
*/
func ==(lhs: LZContact, rhs: LZContact) -> Bool {
    let idMatch = lhs.id == rhs.id
    let nameMatch = lhs.name == rhs.name
    return idMatch && nameMatch
}