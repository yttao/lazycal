//
//  MonthItemCollectionViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/15/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class MonthItemCollectionViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var delegate: MonthItemCollectionViewControllerDelegate?
    
    var dateIndex: NSDate?
    var dateComponents: NSDateComponents?
    
    // Parent view controller
    private var monthItemViewController: MonthItemViewController?
    
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
    private var daysInMonth = [Int?](count: MonthItemCollectionViewController.numCellsInMonth, repeatedValue: nil)
    
    // Calendar used
    private let calendar = NSCalendar.currentCalendar()
    // Currently selected cell
    private var selectedCell: CalendarCollectionViewCell?
    
    // Start weekday
    private var monthStartWeekday = 0
    // Keeps track of current date view components

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Loads initial data
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.delegate = self
        collectionView!.dataSource = self
    }
    
    
    // Loads initial data to use
    func loadData(components: NSDateComponents, delegate: MonthItemCollectionViewControllerDelegate) {
        self.delegate = delegate
        // Copy datecomponents to prevent unexpected changes
        self.dateComponents = components.copy() as? NSDateComponents
        
        monthStartWeekday = getMonthStartWeekday(components)
        
        // Create date index, ensure it is set to day 1 in the month.
        let dateIndexComponents = components.copy()  as? NSDateComponents
        dateIndexComponents!.day = 1
        dateIndex = calendar.dateFromComponents(dateIndexComponents!)
        
        let numDays = self.calendar.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: self.calendar.dateFromComponents(components)!).length
        
        for (var i = monthStartWeekday - 1; i < numDays + (monthStartWeekday - 1); i++) {
            daysInMonth[i] = i - (monthStartWeekday - 2)
        }
    }
    
    
    // Determines number of items in month
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MonthItemCollectionViewController.numCellsInMonth
    }
    
    
    // Makes cell with day number shown
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Check if old selected cell has been properly deselected (fix to small bug when viewing selected event details)
        deselectSelectedCell()

        // Get cell
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CalendarCollectionViewCell
        
        // Select cell
        selectCell(cell)
        
        // Update selected date components
        dateComponents!.day = selectedCell!.dayLabel.text!.toInt()!
        dateComponents = getNewDateComponents(dateComponents!)
        
        // Show events for date
        let selectedDate = calendar.dateFromComponents(dateComponents!)!
        // Select date function
        // Alert delegate that collection view did change selected day
        delegate?.monthItemCollectionViewControllerDidChangeSelectedDate(selectedDate)
    }
    
    
    // Day cells are selectable only if they are a valid day cell
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CalendarCollectionViewCell
        
        if cell.dayLabel.text != nil {
            return true
        }
        return false
    }
    
    
    // Called on deselection of day cell in month
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        deselectSelectedCell()
    }
    
    
    // Clears current selection
    func clearSelected() {
        deselectSelectedCell()
        
        // Reset date components to day 1
        dateComponents!.day = 1
        dateComponents = getNewDateComponents(dateComponents!)
    }
    
    
    func selectCell(cell: CalendarCollectionViewCell) {
        cell.backgroundColor = selectedColor
        selectedCell = cell
    }
    
    
    /*
        @brief Deselects the currently selected cell.
    */
    func deselectSelectedCell() {
        if let cell = selectedCell {
            cell.backgroundColor = backgroundColor
            selectedCell = nil
        }
    }
    
    
    /*
        @brief Gets the first weekday of the month
        @param components The date components of the month.
    */
    func getMonthStartWeekday(components: NSDateComponents) -> Int {
        let componentsCopy = components.copy() as! NSDateComponents
        componentsCopy.day = 1
        let startMonthDate = calendar.dateFromComponents(componentsCopy)
        let startMonthDateComponents = calendar.components(.CalendarUnitWeekday, fromDate: startMonthDate!)
        return startMonthDateComponents.weekday
    }
    
    
    /*
        @brief Returns new date components after components have been modified.
        @param components The components to recalculate
        @return The new date components.
    */
    func getNewDateComponents(components: NSDateComponents) -> NSDateComponents {
        let newDate = calendar.dateFromComponents(components)
        return calendar.components(units, fromDate: newDate!)
    }
}


/*
    @brief Handles cell sizing and spacing.
    @discussion The collection view should take up the
*/
extension MonthItemCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    /*
        @brief Determines size of one cell.
        @discussion Note: due to the iOS Simulator, the rightmost cell is cut off slightly because it has a scrollbar. The sizing is correct on an actual device.
    */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width /
            CGFloat(MonthItemCollectionViewController.numDaysInWeek),
            height: (collectionView.bounds.size.height) /
                CGFloat(MonthItemCollectionViewController.numWeeksInMonth))
    }
    
    // Determines spacing between cells (none)
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    // Determines sizing between sections (none)
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    // Determines inset for section (none)
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
}


// Delegate protocol
protocol MonthItemCollectionViewControllerDelegate {
    func monthItemCollectionViewControllerDidChangeSelectedDate(date: NSDate)
}