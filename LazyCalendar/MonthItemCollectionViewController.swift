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
    
    private var headerHeight: CGFloat?
    
    /**
        Set delegate and data source.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.delegate = self
        collectionView!.dataSource = self
        
        collectionView!.scrollEnabled = false
        
    }
    
    // Loads initial data to use
    func loadData(components: NSDateComponents) {
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
    
    /**
        Resets collection view selection by calling `deselectSelectedCell()` to deselect the currently selected cell and setting date components to the first day in the month.
    */
    func clearSelected() {
        deselectSelectedCell()
        dateComponents!.day = 1
        dateComponents = getNewDateComponents(dateComponents!)
    }
    
    
    /**
        Selects the specified cell.
    
        :param: cell The cell to select.
    */
    func selectCell(cell: CalendarCollectionViewCell) {
        cell.backgroundColor = selectedColor
        selectedCell = cell
    }
    
    
    /**
        Deselects the currently selected cell.
    */
    func deselectSelectedCell() {
        if let cell = selectedCell {
            cell.backgroundColor = backgroundColor
            selectedCell = nil
        }
    }
    
    
    /**
        Gets the first weekday of the month.
    
        :param: components The date components of the month.
    
        :returns: The month start weekday as an int from 1 (Sunday) to 7 (Saturday).
    */
    func getMonthStartWeekday(components: NSDateComponents) -> Int {
        let componentsCopy = components.copy() as! NSDateComponents
        componentsCopy.day = 1
        let startMonthDate = calendar.dateFromComponents(componentsCopy)
        let startMonthDateComponents = calendar.components(.CalendarUnitWeekday, fromDate: startMonthDate!)
        return startMonthDateComponents.weekday
    }
    
    
    /*
        Returns new date components after components have been modified.
    
        :param: components The date components to recalculate.
    
        :return The new date components.
    */
    func getNewDateComponents(components: NSDateComponents) -> NSDateComponents {
        let newDate = calendar.dateFromComponents(components)
        return calendar.components(units, fromDate: newDate!)
    }
}

// MARK: - UICollectionViewDelegate
extension MonthItemCollectionViewController: UICollectionViewDelegate {
    /**
        Day cells are selectable only if they are a valid day cell.
    */
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CalendarCollectionViewCell
        
        if cell.dayLabel.text != nil {
            return true
        }
        return false
    }
    
    /**
        Called on selection of day cell in month.
    */
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
    
    /**
        Called on deselection of day cell in month.
    */
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        deselectSelectedCell()
    }
    
    /**
        When header view is about to be displayed, recalculate cell heights to accomodate header height.
    */
    override func collectionView(collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "MonthItemCollectionHeaderView", forIndexPath: indexPath) as! MonthItemCollectionHeaderView
        headerHeight = header.frame.height
        collectionView.reloadSections(NSIndexSet(index: indexPath.section))
    }
}

// MARK: - UICollectionViewDataSource
extension MonthItemCollectionViewController: UICollectionViewDataSource {
    /**
        Makes cell with day number shown.
    */
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
    /**
        Determines number of items in month.
    */
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MonthItemCollectionViewController.numCellsInMonth
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "MonthItemCollectionHeaderView", forIndexPath: indexPath) as? MonthItemCollectionHeaderView
        println(indexPath)
        header!.createConstraints()
        return header!
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MonthItemCollectionViewController: UICollectionViewDelegateFlowLayout {
    /**
        Determines size of one cell.
        
        Note: due to the iOS Simulator, the rightmost cell is cut off slightly because it has a scrollbar. The sizing is correct on an actual device.
    */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if headerHeight == nil {
            return CGSize(width: collectionView.bounds.size.width /
                CGFloat(MonthItemCollectionViewController.numDaysInWeek),
                height: (collectionView.bounds.size.height) /
                    CGFloat(MonthItemCollectionViewController.numWeeksInMonth))
        }
        else {
            return CGSize(width: collectionView.bounds.size.width /
                CGFloat(MonthItemCollectionViewController.numDaysInWeek),
                height: (collectionView.bounds.size.height - headerHeight!) /
                    CGFloat(MonthItemCollectionViewController.numWeeksInMonth))
        }
    }
    
    /**
        Determines spacing between cells (none).
    */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    /** 
        Determines sizing between sections (none).
    */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    /**
        Determines inset for section (none).
    */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
}

/**
    Delegate protocol for `MonthItemCollectionViewController`.
*/
protocol MonthItemCollectionViewControllerDelegate {
    /**
        Informs the delegate that the selected date was changed.
    
        :param: date The new selected date.
    */
    func monthItemCollectionViewControllerDidChangeSelectedDate(date: NSDate)
}