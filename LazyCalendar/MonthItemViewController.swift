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
    private let segueIdentifier = "ChangeEventSegue"
    
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
    
    /**
        Initialize height constraints.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeHeightConstraints()
    }
    
    /**
        Initialize height constraints for calendar. The height constraint is determined by device size, while the table view container takes up the remaining space.
    
        The height constraint is by default half the screen height but can shrink if there happens to be fewer than 6 rows that need to be displayed (the maximum number of rows that must be displayable).
    */
    func initializeHeightConstraints() {
        monthItemPageViewContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
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
        Sets up necessary data when changing to different view. When about to add an event, calculate
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier != nil && segue.identifier! == segueIdentifier {
            let calendar = NSCalendar.currentCalendar()
            
            // Set initial date as the currently selected date and hours/minutes as current hours/minutes.
            let currentTime = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: NSDate())
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
