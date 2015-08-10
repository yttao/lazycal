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
    private var date: NSDate!
    // The events for selected day
    private var events = [FullEvent]()

    // Reuse identifier for cells
    private let reuseIdentifier = "EventCell"
    // Name of entity to retrieve data from.
    private let entityName = "FullEvent"
    
    private let segueIdentifier = "SelectEventSegue"
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadEvents", name: "EventSaved", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeMonth:", name: "MonthChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeSelectedDate:", name: "SelectedDateChanged", object: nil)
    }
    
    /**
        Initialize table view.
        
        Set data source and delegate to self.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    /**
        On month change, reload navigation title to match month and show events for the first day of the month.
    
        Note: this method is not called when the page view controller is first initialized because it is created after the page view controller.
    
       :param: notification The notification that the month has changed.
    */
    func changeMonth(notification: NSNotification) {
        let monthItemCollectionViewController = notification.userInfo!["ViewController"] as? MonthItemCollectionViewController
        date = NSCalendar.currentCalendar().dateFromComponents(monthItemCollectionViewController!.dateComponents!)
        showEvents(date)
    }
    
    /**
        On selected date change, update the date and events shown.
    
        :param: notification The notification indicating that the selected date was changed.
    */
    func changeSelectedDate(notification: NSNotification) {
        date = notification.userInfo!["Date"] as? NSDate
        showEvents(date)
    }
    
    /**
        Reloads the events
    */
    func reloadEvents() {
        showEvents(date)
    }
    
    /**
        Show events for a date.
    
        :param: date The date to show.
    */
    func showEvents(date: NSDate) {
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
        let requirements = "(dateStart >= %@ AND dateStart < %@) OR (dateEnd >= %@ AND dateEnd < %@) OR (dateStart <= %@ AND dateEnd >= %@) OR (dateStart <= %@ AND dateEnd >= %@)"
        let predicate = NSPredicate(format: requirements, lowerDate, upperDate, lowerDate, upperDate, lowerDate, lowerDate, upperDate, upperDate)
        fetchRequest.predicate = predicate
        
        // Execute fetch request
        var error: NSError? = nil
        events = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [FullEvent]
        
        // Display events sorted by dateStart.
        events.sort({
            let firstDate = $0.dateStart
            let secondDate = $1.dateStart
            if firstDate.compare(secondDate) == .OrderedSame {
                let firstName = $0.name
                let secondName = $1.name
                if firstName != nil && secondName != nil {
                    return firstName!.compare(secondName!) == .OrderedAscending
                }
                else {
                    return true
                }
            }
            return firstDate.compare(secondDate) == .OrderedAscending
            })
        tableView.reloadData()
    }
    
    /**
        Deletes an event from persistent storage, deletes all notifications associated with the event, and removes the event from the listed events in the table view.
    
        :param: event The event to delete.
        :param: indexPath The index path of the event to be deleted from the table view.
    */
    private func deleteEvent(event: FullEvent, atIndexPath indexPath: NSIndexPath) {
        // Deschedule all notifications
        descheduleNotificationsForDeletedEvent(event)
        
        // Remove from persistent storage
        removeEventFromPersistentStorage(event)
        
        // Remove from event
        removeEventFromTableView(event, atIndexPath: indexPath)
    }
    
    /**
        Removes an event from persistent storage.
    
        TODO: Remove connections to other objects (contacts, POIs).
    
        :param: event The event to remove from persistent storage.
    */
    private func removeEventFromPersistentStorage(event: FullEvent) {
        // Delete event
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)!
        managedContext.deleteObject(event)
        
        // Save changes
        var error: NSError?
        if !managedContext.save(&error) {
            assert(false, "Could not save \(error), \(error?.userInfo)")
        }
    }
    
    /**
        Removes the event from the array of events and the table view.
    
        :param: event The event to remove from the table view.
        :param: indexPath The index path to locate the event in the table view.
    */
    private func removeEventFromTableView(event: FullEvent, atIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        events.removeAtIndex(indexPath.row)
        tableView.endUpdates()
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
        for notification in notifications {
            let deletedIndex = find(scheduledNotifications, notification)
            scheduledNotifications.removeAtIndex(deletedIndex!)
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
        return .Delete
    }
    
    /**
        On cell selection, pull up table view to show more information.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = events[indexPath.row]
        
        NSNotificationCenter.defaultCenter().postNotificationName("EventSelected", object: self, userInfo: ["Event": event])
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
        if editingStyle == .Delete {
            let event = events[indexPath.row]
            deleteEvent(event, atIndexPath: indexPath)
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