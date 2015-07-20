//
//  MonthItemViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/8/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import CoreData

class MonthItemViewController: UIViewController, MonthItemCollectionViewControllerDelegate, ChangeEventViewControllerDelegate {
    @IBOutlet weak var monthItemCollectionViewContainer: UIView!
    @IBOutlet weak var monthItemTableViewContainer: UIView!
    
    var monthItemCollectionViewController: MonthItemCollectionViewController?
    var monthItemTableViewController: MonthItemTableViewController?

    // Segue identifier to add an event
    private let changeEventSegueIdentifier = "ChangeEventSegue"
    private let collectionViewSegueIdentifier = "CollectionViewSegue"
    private let tableViewSegueIdentifier = "TableViewSegue"
    
    // NSCalendarUnits to keep track of
    private let units = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth |
        NSCalendarUnit.CalendarUnitDay
    
    // Keeps track of current date view components
    private var dateComponents: NSDateComponents?
    
    
    // Initializer
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    // Loads initial data
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add height constraint determined by device size
        let heightConstraint = NSLayoutConstraint(item: monthItemCollectionViewContainer, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: CGFloat(view.frame.size.height / 2))
        monthItemCollectionViewContainer.addConstraint(heightConstraint)
    }

    
    // Loads initial data to use
    func loadData(components: NSDateComponents) {
        dateComponents = components
        
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
            case collectionViewSegueIdentifier:
                monthItemCollectionViewController = segue.destinationViewController as? MonthItemCollectionViewController
                monthItemCollectionViewController!.loadData(dateComponents!, delegate: self)
            case tableViewSegueIdentifier:
                monthItemTableViewController = segue.destinationViewController as? MonthItemTableViewController
                monthItemTableViewController!.date = NSCalendar.currentCalendar().dateFromComponents(dateComponents!)
                break
            default:
                break
            }
        }
        
    }
    
    
    func monthItemCollectionViewControllerDidChangeSelectedDate(date: NSDate) {
        // On date selection, show events for that date
        monthItemTableViewController!.showEvents(date)
    }
    
    
    /*
        @brief After saving an event, show the new event if it is in the current table view.
    */
    func changeEventViewControllerDidSaveEvent(event: NSManagedObject) {
        let selectedDate = NSCalendar.currentCalendar().dateFromComponents(monthItemCollectionViewController!.dateComponents!)
        monthItemTableViewController!.showEvents(selectedDate!)
    }
    

    @IBAction func saveEvent(segue: UIStoryboardSegue) {
        monthItemTableViewController!.tableView!.reloadData()
        println("Save")
    }
    
    
    @IBAction func cancelEvent(segue: UIStoryboardSegue) {
        println("Cancel")
    }
}