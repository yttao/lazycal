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
    
    
    required init!(coder aDecoder: NSCoder!) {
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
            //cell!.textLabel!.text = event.valueForKey("name") as? String
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
        
        // Format for finding data
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = NSCalendar.currentCalendar()
        
        var error: NSError? = nil
        println("***ALL***")
        let allEvents = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]
        for (var i = 0; i < allEvents.count; i++) {
            println(allEvents[i].valueForKey("dateStart"))
        }
        
        let fullDay = NSTimeInterval(60 * 60 * 24)
        let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
        let lowerDate: NSDate = calendar.dateFromComponents(components)!
        let upperDate: NSDate = lowerDate.dateByAddingTimeInterval(fullDay)
        
        let requirements = "(dateStart >= %@) AND (dateStart < %@)"
        let predicate = NSPredicate(format: requirements, lowerDate, upperDate)
        fetchRequest.predicate = predicate
        //println(fetchRequest.predicate)
        
        
        // Execute fetch request
        events = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]
        println("***SELECTED***")
        for (var i = 0; i < events.count; i++) {
            var dateStart = events[i].valueForKey("dateStart") as! NSDate
            var name = events[i].valueForKey("name") as! String
            println(dateStart)
            println(name)
        }
        
        // Display events (no order for now)
        tableView.reloadData()
    }
}
