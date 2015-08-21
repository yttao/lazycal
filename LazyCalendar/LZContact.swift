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
    
    // MARK: - Non-stored/computed properties
    
    var storedEvents: NSMutableSet {
        return mutableSetValueForKey("events")
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