//
//  MonthItemTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/15/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import CoreData

class MonthItemTableViewController: UITableViewController {
    var date: NSDate?
    // The events for selected day
    private var events = [FullEvent]()

    // Reuse identifier for cells
    private let reuseIdentifier = "EventCell"
    // Name of entity to retrieve data from.
    private let entityName = "FullEvent"
    
    private var selectEventTableViewController: SelectEventTableViewController?
    
    private let segueIdentifier = "SelectEventSegue"
    
    /**
        Initialize table view.
        
        Set data source and delegate to self.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        showEvents(date!)
    }
    
    /**
    
    */
    func reloadEvents() {
        showEvents(date!)
    }
    
    /**
        Show events in table form for a date.
    */
    func showEvents(date: NSDate) {
        self.date = date
        //println("Showing events for \(date)")
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
        
        // To show an event, the time interval from dateStart to dateEnd must fall between lowerDate and upperDate.
        // (dateStart >= lower && dateStart < upper) || (dateEnd >= lower && dateEnd < upper) || (dateStart < lower && dateEnd >= lower) || (dateStart < upper && dateEnd >= upper)
        let requirements = "(dateStart >= %@ && dateStart < %@) || (dateEnd >= %@ && dateEnd < %@) || (dateStart <= %@ && dateEnd >= %@) || (dateStart <= %@ && dateEnd >= %@)"
        let predicate = NSPredicate(format: requirements, lowerDate, upperDate, lowerDate, upperDate, lowerDate, lowerDate, upperDate, upperDate)
        fetchRequest.predicate = predicate
        
        // Execute fetch request
        var error: NSError? = nil
        events = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [FullEvent]
        
        // Display events sorted by dateStart.
        //TODO: Add an additional alphabetical sort for two dateStarts at the same times.
        events.sort({
            let firstDate = $0.dateStart
            let secondDate = $1.dateStart
            return firstDate.compare(secondDate) == .OrderedAscending
            })
        tableView.reloadData()
    }
    
    
    /**
        Initializes information on segue to selected event details view.
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != nil && segue.identifier == segueIdentifier {
            let selectEventNavigationController = segue.destinationViewController as! UINavigationController
            selectEventTableViewController = selectEventNavigationController.viewControllers.first as? SelectEventTableViewController
            selectEventTableViewController!.delegate = self
        }
    }
    
    /**
        Leaves event details back to main view.
    */
    @IBAction func leaveEventDetails(segue: UIStoryboardSegue) {
    }
}

// MARK: - UITableViewDelegate
extension MonthItemTableViewController: UITableViewDelegate {
    /**
        Prevents indenting for showing circular edit button on the left when editing.
    */
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    /**
        Gives option to delete event.
    */
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    /**
        On cell selection, pull up table view to show more information.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = events[indexPath.row]
        
        selectEventTableViewController!.loadData(event)
    }
}

// MARK: - UITableViewDataSource
extension MonthItemTableViewController: UITableViewDataSource {
    /**
        There is 1 section in the table.
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
        Determines the number of rows in the table (equals the number of events on that day).
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    /**
        Allow table cells to be deleted.
    
        Note: If tableView.editing = true, the left circular edit option will appear.
    */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    /**
        If delete is pressed on swipe left, delete the event.
    */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)!
            let event = events[indexPath.row]
            
            descheduleNotificationsForDeletedEvent(event)
            
            // Delete event
            managedContext.deleteObject(event)
            
            // Save changes
            var error: NSError?
            if !managedContext.save(&error) {
                assert(false, "Could not save \(error), \(error?.userInfo)")
            }
            
            // Remove event from array and table view
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            events.removeAtIndex(indexPath.row)
            tableView.endUpdates()
        }
    }
    
    /**
        Deschedules notifications for a deleted event.
    
        If no notifications are found, it does nothing.
    
        :param: event The event that has notifications to deschedule.
    */
    func descheduleNotificationsForDeletedEvent(event: FullEvent) {
        // Get all notifications
        var scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
        // Get notifications to remove
        let notifications = scheduledNotifications.filter({(
            $0.userInfo!["id"] as! String) == event.id
        })
        // Remove scheduled notifications
        for (index, notification) in enumerate(notifications) {
            let index = find(scheduledNotifications, notification)
            scheduledNotifications.removeAtIndex(index!)
        }
    }
    
    /**
        Shows the event name and date start to date end.
        
        The event name appears in the event main label and the date in the details label.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! UITableViewCell
        let event = events[indexPath.row]
        if let name = event.name {
            cell.textLabel?.text = name
        }
        else {
            cell.textLabel?.text = nil
        }
        
        return cell
    }
}

// MARK: - SelectEventTableViewControllerDelegate
extension MonthItemTableViewController: SelectEventTableViewControllerDelegate {
    /**
        On changing event, update events for current table view.
    */
    func selectEventTableViewControllerDidChangeEvent(event: FullEvent) {
        showEvents(date!)
    }
}

// MARK: - ChangeEventViewControllerDelegate
extension MonthItemTableViewController: ChangeEventViewControllerDelegate {
    /**
        On changing event, update events for current table view.
    */
    func changeEventViewControllerDidSaveEvent(event: FullEvent) {
        showEvents(date!)
    }
}