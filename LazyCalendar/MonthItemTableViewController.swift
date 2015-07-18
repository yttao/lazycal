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
    // The events for selected day
    private var events = [NSManagedObject]()
    // Reuse identifier for cells
    private let reuseIdentifier = "EventCell"
    // Name of entity to retrieve data from.
    private let entityName = "TestEvent"
    // Cell height
    private let cellHeight = UITableViewCell().frame.height
    
    private let changeEventSegueIdentifier = "ChangeEventSegue"
    
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    
    /*
        @brief Initialize table view.
        @discussion Set data source and delegate to self.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    

    /*
        @brief Determines the number of sections in the table.
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    

    /*
        @brief Determines the number of rows in the table (equals the number of events on that day).
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    
    /*
        @brief Shows the event name and date start to date end.
        @discussion The event name appears in the event main label and the date in the details label.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as? EventTableViewCell
        let event = events[indexPath.row]
        if event.valueForKey("name") as? String != nil {
            cell?.eventNameLabel.text = event.valueForKey("name") as? String
        }
        
        return cell!
    }
    
    
    /*
        @brief Allow table cells to be deleted.
        @discussion Note: If tableView.editing = true, the left circular edit option will appear.
    */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    /*
        @brief
    */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        println("Editing")
        if editingStyle == UITableViewCellEditingStyle.Delete {
            println("Deleting")
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)!
            let event = events[indexPath.row]

            // Delete event
            managedContext.deleteObject(event)
            
            // Save changes
            var error: NSError?
            if !managedContext.save(&error) {
                assert(false, "Could not save \(error), \(error?.userInfo)")
            }
            
            // Remove event from list and reload
            events.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
    
    
    /*
        @brief Gives option to delete event.
    */
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    
    /*
        @brief Prevents indenting for showing circular edit button on the left when editing.
    */
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    /*
        @brief Cells cannot be reordered (set to chronological order for now).
    */
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    /*
        @brief On cell selection, pull up table view to show more information.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get cell and associated event
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let event = events[indexPath.row]
        
        // Pull up more event info
    }
    
    
    /*
        @brief Cell heights are standard table view cell heights.
    */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    
    /*
        @brief Show events in table form for a date.
    */
    func showEvents(date: NSDate) {
        println("Showing events for \(date)")
        // Find events for that date
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)!
        
        // Create fetch request for data
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
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
        
        // Display events sorted by dateStart. 
        //TODO: Add an additional alphabetical sort for two dateStarts at the same times.
        events.sort({($0.valueForKey("dateStart") as! NSDate).compare(($1.valueForKey("dateStart") as! NSDate)) == .OrderedAscending})
        tableView.reloadData()
    }
    
    
    /*
        @brief Initializes information on segue to event details view.
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == changeEventSegueIdentifier {
            let calendar = NSCalendar.currentCalendar()
            
            // Get current hour and minute
            let currentTime = calendar.components(NSCalendarUnit.CalendarUnitHour |
                NSCalendarUnit.CalendarUnitMinute, fromDate: NSDate())
            
            // Load ChangeEventViewController with loadData(withPreexistingEvent:)
        }
    }
    
    
    @IBAction func leaveEventDetails(segue: UIStoryboardSegue) {
        println("Leave")
    }
}
