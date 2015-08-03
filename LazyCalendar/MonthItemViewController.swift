//
//  MonthItemViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/8/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import CoreData

class MonthItemViewController: UIViewController {
    @IBOutlet weak var monthItemPageViewContainer: UIView!
    @IBOutlet weak var monthItemTableViewContainer: UIView!

    // Segue identifier to add an event
    private let changeEventSegueIdentifier = "ChangeEventSegue"
    
    // NSCalendarUnits to keep track of
    private let units: NSCalendarUnit = .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay
    
    private var date: NSDate?
    
    // Initializer
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        // Observer for when notification pops up
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showEventNotification:", name: "EventNotificationReceived", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeMonths:", name: "MonthChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateDate:", name: "SelectedDateChanged", object: nil)
    }
    
    
    // Loads initial data
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add height constraint determined by device size, table view container takes up the remaining space.
        let heightConstraint = NSLayoutConstraint(item: monthItemPageViewContainer, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: CGFloat(view.frame.size.height / 2))
        monthItemPageViewContainer.addConstraint(heightConstraint)
    }
    
    /**
        Update the date.
    
        :param: notification The notification indicating that the selected date was changed.
    */
    func updateDate(notification: NSNotification) {
        date = notification.userInfo!["Date"] as? NSDate
    }
    
    /**
        Loads the navigation title.
    
        :param: components The date components to determine the navigation title.
    */
    func loadNavigationTitle(components: NSDateComponents) {
        // Gets month in string format
        let dateFormatter = NSDateFormatter()
        let months = dateFormatter.monthSymbols
        let monthSymbol = months[components.month - 1] as! String
        
        // Sets title as month year
        self.navigationItem.title = "\(monthSymbol) \(components.year)"
    }
    
    /**
        On month change, reload navigation title to match month and show events for the first day of the month.
    
        :param: notification The notification that the month has changed.
    */
    func changeMonths(notification: NSNotification) {
        let monthItemCollectionViewController = notification.userInfo!["ViewController"] as? MonthItemCollectionViewController
        loadNavigationTitle(monthItemCollectionViewController!.dateComponents!)
    }
    
    /**
        Sets up necessary data when changing to different view.
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier != nil && segue.identifier! == changeEventSegueIdentifier {
            let calendar = NSCalendar.currentCalendar()
            
            // Get current hour and minute
            let currentTime = calendar.components(NSCalendarUnit.CalendarUnitHour |
                NSCalendarUnit.CalendarUnitMinute, fromDate: NSDate())
            
            // Set initial date choice on date picker as selected date, at current hour and minute
            let dateComponents = calendar.components(units, fromDate: date!)
            dateComponents.hour = currentTime.hour
            dateComponents.minute = currentTime.minute
            let initialDate = calendar.dateFromComponents(dateComponents)
            
            // Find view controller for adding events
            let navigationController = segue.destinationViewController as! UINavigationController
            let addEventViewController = navigationController.viewControllers.first as! ChangeEventViewController
            // Set initial date information for event
            addEventViewController.loadData(dateStart: initialDate!)
        }
    }
    
    /**
        Show an alert for the event notification. The alert provides two options: "OK" and "View Event". Tap "OK" to dismiss the alert. Tap "View Event" to show event details.
    
        This is only called if this view controller is loaded and currently visible.
    
        :param: notification The notification that a local notification was received.
    */
    func showEventNotification(notification: NSNotification) {
        if isViewLoaded() && view?.window != nil {
            let localNotification = notification.userInfo!["LocalNotification"] as! UILocalNotification
            
            let alertController = UIAlertController(title: "\(localNotification.alertTitle)", message: "\(localNotification.alertBody!)", preferredStyle: .Alert)
            
            let viewEventAlertAction = UIAlertAction(title: "View Event", style: .Default, handler: {
                (action: UIAlertAction!) in
                let selectEventNavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("SelectEventNavigationController") as! UINavigationController
                let selectEventTableViewController = selectEventNavigationController.viewControllers.first as! SelectEventTableViewController
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext!
                
                let id = localNotification.userInfo!["id"] as! String
                let requirements = "(id == %@)"
                let predicate = NSPredicate(format: requirements, id)
                
                let fetchRequest = NSFetchRequest(entityName: "FullEvent")
                fetchRequest.predicate = predicate
                
                var error: NSError? = nil
                let results = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [FullEvent]
                
                if results != nil && results!.count > 0 {
                    let event = results!.first!
                    NSNotificationCenter.defaultCenter().postNotificationName("EventSelected", object: self, userInfo: ["Event": event])
                }
                
                self.showViewController(selectEventTableViewController, sender: self)
            })
            
            let okAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            
            alertController.addAction(viewEventAlertAction)
            alertController.addAction(okAlertAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    /**
        Unwind segue on saving event.
    */
    @IBAction func saveEvent(segue: UIStoryboardSegue) {
    }
    
    /**
        Unwind segue on cancelling event.
    */
    @IBAction func cancelEvent(segue: UIStoryboardSegue) {
    }
}
