//
//  Models.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/24/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import Foundation
import CoreData

class FullEvent: NSManagedObject {
    @NSManaged var id: String
    
    @NSManaged var name: String?
    
    @NSManaged var dateStart: NSDate
    @NSManaged var dateEnd: NSDate
    
    @NSManaged var alarm: Bool
    @NSManaged var alarmTime: NSDate?
    
    @NSManaged var contacts: NSSet
    @NSManaged var pointsOfInterest: NSSet
}

class Contact: NSManagedObject {
    @NSManaged var id: Int32
    
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    
    @NSManaged var events: NSSet
}

class PointOfInterest: NSManagedObject {
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    
    @NSManaged var title: String?
    @NSManaged var subtitle: String?
    
    @NSManaged var events: NSSet
}