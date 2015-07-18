//
//  MonthItemTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/15/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import CoreData

class MonthItemTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {

    private var events = [NSManagedObject]()
    private let reuseIdentifier = "EventCell"
    
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as? EventTableViewCell
        let event = events[indexPath.row]
        if event.valueForKey("name") as? String != nil {
            cell?.eventNameLabel.text = event.valueForKey("name") as? String
        }
        
        
        return cell!
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewCell().frame.height
    }
    
    
    // Show events in table form for a date
    func showEvents(date: NSDate) {
        println("Showing events for \(date)")
        // Find events for that date
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("TestEvent", inManagedObjectContext: managedContext)!
        
        // Create fetch request for data
        let fetchRequest = NSFetchRequest(entityName: "TestEvent")
        
        let calendar = NSCalendar.currentCalendar()
        
        // 1 day time interval in seconds
        let fullDay = NSTimeInterval(60 * 60 * 24)
        let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
        // Lower limit on date of events is midnight of that day (inclusive)
        let lowerDate: NSDate = calendar.dateFromComponents(components)!
        // Upper limit on date of events is midnight of next day (not inclusive)
        let upperDate: NSDate = lowerDate.dateByAddingTimeInterval(fullDay)
        
        // Requirements to show an event: the time interval from dateStart to dateEnd must fall between lowerDate and upperDate
        // (dateStart >= lower && dateStart < upper) || (dateEnd >= lower && dateEnd < upper) || (dateStart < lower && dateEnd >= lower) || (dateStart < upper && dateEnd >= upper)
        let requirements = "(dateStart >= %@ && dateStart < %@) || (dateEnd >= %@ && dateEnd < %@) || (dateStart <= %@ && dateEnd >= %@) || (dateStart <= %@ && dateEnd >= %@)"
        let predicate = NSPredicate(format: requirements, lowerDate, upperDate, lowerDate, upperDate, lowerDate, lowerDate, upperDate, upperDate)
        fetchRequest.predicate = predicate
        
        
        // Execute fetch request
        var error: NSError? = nil
        events = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]
        println("***SELECTED***")
        /*for (var i = 0; i < events.count; i++) {
            var dateStart = events[i].valueForKey("dateStart") as! NSDate
            var name = events[i].valueForKey("name") as! String
        }*/
        
        // Display events sorted by dateStart. (Later add an additional alphabetical sort for two dateStarts at the same times.)
        events.sort({($0.valueForKey("dateStart") as! NSDate).compare(($1.valueForKey("dateStart") as! NSDate)) == .OrderedAscending})
        tableView.reloadData()
    }
}
