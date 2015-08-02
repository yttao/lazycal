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
    
    var monthItemPageViewController: MonthItemPageViewController?
    var monthItemCollectionViewController: MonthItemCollectionViewController?
    var monthItemTableViewController: MonthItemTableViewController?

    // Segue identifier to add an event
    private let changeEventSegueIdentifier = "ChangeEventSegue"
    private let pageViewSegueIdentifier = "PageViewSegue"
    private let tableViewSegueIdentifier = "TableViewSegue"
    
    // NSCalendarUnits to keep track of
    private let units = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth |
        NSCalendarUnit.CalendarUnitDay
    
    
    // Initializer
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    // Loads initial data
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add height constraint determined by device size
        let heightConstraint = NSLayoutConstraint(item: monthItemPageViewContainer, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: CGFloat(view.frame.size.height / 2))
        monthItemPageViewContainer.addConstraint(heightConstraint)
        
        // Observer for when notification pops up
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showEventNotification:", name: "EventNotificationShouldFire", object: nil)
    }

    
    // Loads initial data to use
    func loadNavigationTitle(components: NSDateComponents) {
        // Gets month in string format
        let dateFormatter = NSDateFormatter()
        let months = dateFormatter.monthSymbols
        let monthSymbol = months[components.month - 1] as! String
        
        // Sets title as month year
        self.navigationItem.title = "\(monthSymbol) \(components.year)"
    }
    
    /**
    Show an alert for the event notification.
    
    This is only called if this view controller is currently visible.
    
    :param: notification The notification from the subject to the observer.
    */
    func showEventNotification(notification: NSNotification) {
        if isViewLoaded() && view?.window != nil {
            let localNotification = notification.userInfo!["LocalNotification"] as! UILocalNotification
            
            let alertController = UIAlertController(title: "\(localNotification.alertTitle)", message: "\(localNotification.alertBody!)", preferredStyle: .Alert)
            
            let viewEventAlertAction = UIAlertAction(title: "View Event", style: .Default, handler: {
                (action: UIAlertAction!) in
                let selectEventNavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("SelectEventNavigationController") as! UINavigationController
                let selectEventTableViewController = selectEventNavigationController.viewControllers.first as! SelectEventTableViewController
                self.showViewController(selectEventTableViewController, sender: self)
            })
            
            let okAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            
            alertController.addAction(viewEventAlertAction)
            alertController.addAction(okAlertAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // Sets up necessary data when changing to different view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let identifier = segue.identifier {
            switch identifier {
            case changeEventSegueIdentifier:
                let calendar = NSCalendar.currentCalendar()
                
                // Get current hour and minute
                let currentTime = calendar.components(NSCalendarUnit.CalendarUnitHour |
                    NSCalendarUnit.CalendarUnitMinute, fromDate: NSDate())
                
                let initialDateComponents = monthItemCollectionViewController!.dateComponents!.copy() as! NSDateComponents
                initialDateComponents.hour = currentTime.hour
                initialDateComponents.minute = currentTime.minute
                
                // Set initial date choice on date picker as selected date, at current hour and minute
                let initialDate = calendar.dateFromComponents(initialDateComponents)
                
                // Find view controller for adding events
                let navigationController = segue.destinationViewController as! UINavigationController
                let addEventViewController = navigationController.viewControllers.first as! ChangeEventViewController
                // Set initial date information for event
                addEventViewController.loadData(dateStart: initialDate!)
                // Delegate to be informed of new event is table view.
                addEventViewController.delegate = monthItemTableViewController
            case pageViewSegueIdentifier:
                monthItemPageViewController = segue.destinationViewController as? MonthItemPageViewController
                monthItemPageViewController!.monthItemViewController = self
                monthItemPageViewController!.customDelegate = self
                loadNavigationTitle(monthItemPageViewController!.dateComponents)
            case tableViewSegueIdentifier:
                monthItemTableViewController = segue.destinationViewController as? MonthItemTableViewController
                monthItemTableViewController!.date = NSCalendar.currentCalendar().dateFromComponents(monthItemPageViewController!.dateComponents)
                break
            default:
                break
            }
        }
        
    }

    @IBAction func saveEvent(segue: UIStoryboardSegue) {
        monthItemTableViewController!.reloadEvents()
    }
    
    
    @IBAction func cancelEvent(segue: UIStoryboardSegue) {
    }
}

extension MonthItemViewController: MonthItemCollectionViewControllerDelegate {
    /**
        On date selection, show events for that date.
        
        :param: date The currently selected date.
    */
    func monthItemCollectionViewControllerDidChangeSelectedDate(date: NSDate) {
        monthItemTableViewController!.showEvents(date)
    }
}

// MARK: - MonthItemPageViewControllerDelegate
extension MonthItemViewController: MonthItemPageViewControllerDelegate {
    func monthItemPageViewControllerDidChangeCurrentViewController(monthItemCollectionViewController: MonthItemCollectionViewController) {
        self.monthItemCollectionViewController = monthItemCollectionViewController
        loadNavigationTitle(monthItemCollectionViewController.dateComponents!)
        if monthItemTableViewController != nil {
            monthItemTableViewController!.showEvents(monthItemCollectionViewController.dateIndex!)
        }
    }
}