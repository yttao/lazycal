//
//  MonthItemViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/8/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import CoreData

class MonthItemViewController: UIViewController, MonthItemCollectionViewControllerDelegate, ChangeEventViewControllerDelegate, MonthItemPageViewControllerDelegate {
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
                addEventViewController.delegate = self
            case pageViewSegueIdentifier:
                monthItemPageViewController = segue.destinationViewController as? MonthItemPageViewController
                monthItemPageViewController!.monthItemViewController = self
                monthItemPageViewController!.customDelegate = self
                loadNavigationTitle(monthItemPageViewController!.dateComponents!)
            case tableViewSegueIdentifier:
                monthItemTableViewController = segue.destinationViewController as? MonthItemTableViewController
                monthItemTableViewController!.date = NSCalendar.currentCalendar().dateFromComponents(monthItemPageViewController!.dateComponents!)
                break
            default:
                break
            }
        }
        
    }
    
    
    func monthItemPageViewControllerDidChangeCurrentViewController(monthItemCollectionViewController: MonthItemCollectionViewController) {
        self.monthItemCollectionViewController = monthItemCollectionViewController
        loadNavigationTitle(monthItemCollectionViewController.dateComponents!)
        if monthItemTableViewController != nil {
            monthItemTableViewController!.showEvents(
                monthItemCollectionViewController.dateIndex!)
        }
    }
    
    
    func monthItemCollectionViewControllerDidChangeSelectedDate(date: NSDate) {
        // On date selection, show events for that date
        monthItemTableViewController!.showEvents(date)
    }
    
    
    /*
        @brief After saving an event, show the new event if it is in the current table view.
    */
    func changeEventViewControllerDidSaveEvent(event: TestEvent) {
        let selectedDate = NSCalendar.currentCalendar().dateFromComponents(monthItemCollectionViewController!.dateComponents!)
        monthItemTableViewController!.showEvents(selectedDate!)
    }
    

    @IBAction func saveEvent(segue: UIStoryboardSegue) {
        monthItemTableViewController!.tableView!.reloadData()
    }
    
    
    @IBAction func cancelEvent(segue: UIStoryboardSegue) {
    }
}