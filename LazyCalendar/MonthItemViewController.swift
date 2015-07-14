//
//  MonthItemViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/8/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class MonthItemViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var monthItemCollectionView: UICollectionView!
    @IBOutlet weak var monthItemTableView: UITableView!
    
    // Used to order months
    var dateIndex: NSDate?

    // Segue identifier to add an event
    private let addEventSegueIdentifier = "AddEventSegue"
    
    // 7 days in a week
    private static let numDaysInWeek = 7
    // Max number of weeks that can be displayed
    private static let numWeeksInMonth = 6
    // Max number of cells (7 days * 6 rows)
    private static let numCellsInMonth = 42
    
    // Colors used
    private let backgroundColor = UIColor(red: 125, green: 255, blue: 125, alpha: 0)
    private let selectedColor = UIColor.yellowColor()
    
    // Calendar cell reuse identifier
    private let reuseIdentifier = "DayCell"
    
    // NSCalendarUnits to keep track of
    private let units = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth |
        NSCalendarUnit.CalendarUnitDay
    
    // Array indexing table view cells
    private var daysInMonth = [Int?](count: MonthItemViewController.numCellsInMonth, repeatedValue: nil)
    // Calendar used
    private let calendar = NSCalendar.currentCalendar()
    // Currently selected cell
    private var selectedCell: CalendarCollectionViewCell?
    // Start weekday
    private var monthStartWeekday = 0
    // Keeps track of current date view components
    private var dateComponents: NSDateComponents?
    
    
    // Initializer
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    // Loads initial data
    override func viewDidLoad() {
        super.viewDidLoad()
        monthItemCollectionView.delegate = self
        monthItemCollectionView.dataSource = self
        
        // Add height constraint determined by device size
        let heightConstraint = NSLayoutConstraint(item: monthItemCollectionView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: CGFloat(view.frame.size.height / 2))
        monthItemCollectionView.addConstraint(heightConstraint)
        println(monthItemCollectionView.frame.height)
        println(monthItemTableView.frame.height)
    }

    
    // Loads initial data to use
    func loadData(dateComponents: NSDateComponents) {
        // Copy datecomponents to prevent unexpected changes
        self.dateComponents = dateComponents.copy() as? NSDateComponents
        
        monthStartWeekday = getMonthStartWeekday(self.dateComponents!)
        
        dateIndex = calendar.dateFromComponents(self.dateComponents!)
        
        let numDays = self.calendar.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: self.calendar.dateFromComponents(self.dateComponents!)!).length
        
        for (var i = monthStartWeekday - 1; i < numDays + (monthStartWeekday - 1); i++) {
            daysInMonth[i] = i - (monthStartWeekday - 2)
        }
        
        // Gets month in string format
        let dateFormatter = NSDateFormatter()
        let months = dateFormatter.monthSymbols
        let monthSymbol = months[dateComponents.month - 1] as! String
        
        // Sets title as month year
        self.navigationItem.title = "\(monthSymbol) \(dateComponents.year)"
    }
    
    
    // Determines number of items in month
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MonthItemViewController.numCellsInMonth
    }
    
    
    // Makes cell with day number shown
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CalendarCollectionViewCell
        
        // Set day number for cell (if it is a valid cell in that month
        if let day = daysInMonth[indexPath.row] {
            cell.dayLabel.text = String(day)
        }
        else {
            cell.dayLabel.text = nil
        }
        
        return cell
    }
    
    
    // Called on selection of day cell in month
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Get cell
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CalendarCollectionViewCell
        
        // Select cell
        cell.backgroundColor = selectedColor
        selectedCell = cell
            
        // Update selected date components
        dateComponents!.day = selectedCell!.dayLabel.text!.toInt()!
        dateComponents = getNewDateComponents(dateComponents!)
            
        // Show events for date
        let selectedDate = calendar.dateFromComponents(dateComponents!)
        ShowEvents(selectedDate!)
    }
    
    
    // Day cells are selectable only if they are a valid day cell
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CalendarCollectionViewCell
        
        if cell.dayLabel.text != nil {
            return true
        }
        return false
    }
    
    
    // Called on deselection of day cell in month
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        // Reset cell color and clear selectedCell
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CalendarCollectionViewCell

        cell.backgroundColor = backgroundColor
        selectedCell = nil
    }
    
    
    // Clears current selection
    func clearSelected() {
        if selectedCell != nil {
            selectedCell!.backgroundColor = backgroundColor
            selectedCell = nil
        }

        // Reset date components to day 1
        dateComponents!.day = 1
        dateComponents = getNewDateComponents(dateComponents!)
    }
    
    
    // Gets the first weekday of the month
    func getMonthStartWeekday(components: NSDateComponents) -> Int {
        let componentsCopy = components.copy() as! NSDateComponents
        componentsCopy.day = 1
        let startMonthDate = calendar.dateFromComponents(componentsCopy)
        let startMonthDateComponents = calendar.components(.CalendarUnitWeekday, fromDate: startMonthDate!)
        return startMonthDateComponents.weekday
    }
    
    
    // Recalculates components after fields have been changed in components
    func getNewDateComponents(components: NSDateComponents) -> NSDateComponents {
        let newDate = calendar.dateFromComponents(components)
        return calendar.components(units, fromDate: newDate!)
    }
    
    // Shows events for a date
    func ShowEvents(date: NSDate) {
        println(date)
    }
    
    
    // Sets up necessary data when changing to different view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        // True if adding an event
        if segue.identifier == addEventSegueIdentifier {
            // Get current hour and minute
            let currentTime = calendar.components(NSCalendarUnit.CalendarUnitHour |
                NSCalendarUnit.CalendarUnitMinute, fromDate: NSDate())
            
            let initialDateComponents = dateComponents!.copy() as! NSDateComponents
            initialDateComponents.hour = currentTime.hour
            initialDateComponents.minute = currentTime.minute
            
            // Set initial date choice on date picker as selected date, at current hour and minute
            let initialDate = calendar.dateFromComponents(initialDateComponents)
            
            // Find view controller for adding events
            let navigationController = segue.destinationViewController as! UINavigationController
            let addEventViewController = navigationController.viewControllers.first as! ChangeEventViewController
            // Set initial date information for event
            addEventViewController.setInitialDate(initialDate!)
        }
    }
    
    
    // Called on event cancel, returns to current month view
    @IBAction func cancelEvent(segue: UIStoryboardSegue) {
        println("Cancelled event")
    }
    
    
    // Called on event save
    @IBAction func saveEvent(segue: UIStoryboardSegue) {
        println("Saved event")
    }
}

// Handles cell sizing
extension MonthItemViewController: UICollectionViewDelegateFlowLayout {
    
    // Determines size of one cell
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width /
            CGFloat(MonthItemViewController.numDaysInWeek),
            height: (collectionView.frame.size.height) /
                CGFloat(MonthItemViewController.numWeeksInMonth))
    }
    
    // Determines spacing between cells (none)
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    // Determines sizing between sections (none)
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    // Determines inset for section (none)
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
}