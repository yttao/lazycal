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
    private static let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    private static let entity = NSEntityDescription.entityForName("LZContact", inManagedObjectContext: LZContact.managedContext)!
    
    @NSManaged var id: Int32
    
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    
    @NSManaged var events: NSSet
    
    var storedEvents: NSMutableSet {
        return mutableSetValueForKey("events")
    }
    
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
        super.init(entity: LZContact.entity, insertIntoManagedObjectContext: LZContact.managedContext)
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
}

/**
    Two `LZContacts` are equal if their id's, first names, and last names match.

    :param: lhs The first `LZContact`.
    :param: rhs The second `LZContact`.
    :returns: `true` if the `LZContacts` have the same `id`, `firstName` , and `lastName` properties; `false` otherwise.
*/
func ==(lhs: LZContact, rhs: LZContact) -> Bool {
    let idMatch = lhs.id == rhs.id
    let nameMatch = lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName
    return idMatch && nameMatch
}