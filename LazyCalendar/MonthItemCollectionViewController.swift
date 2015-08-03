//
//  MonthItemCollectionViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/15/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class MonthItemCollectionViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var dateIndex: NSDate?
    var dateComponents: NSDateComponents?
    
    // 7 days in a week
    private let daysInWeek = 7
    // Max number of rows that can be displayed, 1 row per week
    private let rowsInMonth = 6
    // Max number of cells (7 days * 6 rows)
    private let cellsInMonth = 42
    
    // Colors used
    private let backgroundColor = UIColor(red: 125, green: 255, blue: 125, alpha: 0)
    private let selectedColor = UIColor.yellowColor()
    
    // Calendar cell reuse identifier
    private let reuseIdentifier = "DayCell"
    
    // NSCalendarUnits to keep track of
    private let units = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth |
        NSCalendarUnit.CalendarUnitDay
    
    // Array indexing table view cells
    private var daysInMonth: [Int?]
    
    // Calendar used
    private let calendar = NSCalendar.currentCalendar()
    // Currently selected cell
    private var selectedCell: CalendarCollectionViewCell?
    
    // Start weekday
    private var monthStartWeekday = 0
    // Keeps track of current date view components
    
    // Size of header
    private let headerHeight: CGFloat = 30
    
    required init(coder aDecoder: NSCoder) {
        daysInMonth = [Int?](count: cellsInMonth, repeatedValue: nil)
        
        super.init(coder: aDecoder)
    }
    
    /**
        Set delegate and data source, disable scrolling (page scrolling still allowed though).
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.delegate = self
        collectionView!.dataSource = self
        
        collectionView!.scrollEnabled = false
    }
    
    /**
        On view appearance, reload data to ensure proper cell reselection when after switching months.
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Deselect currently selected cell (cell will be reused on reloadData)
        deselectSelectedCell()
        
        collectionView!.reloadData()
    }
    
    /**
        Loads initial data that the view controller uses to generate the calendar view.
    
        :param: components The date components corresponding to the month.
    */
    func loadData(components: NSDateComponents) {
        // Copy datecomponents to prevent unexpected changes
        dateComponents = components.copy() as? NSDateComponents
        
        monthStartWeekday = getMonthStartWeekday(components)
        
        // Create date index, ensure it is set to day 1 in the month.
        let dateIndexComponents = components.copy()  as? NSDateComponents
        dateIndexComponents!.day = 1
        dateIndex = calendar.dateFromComponents(dateIndexComponents!)
        
        let numDays = calendar.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: calendar.dateFromComponents(components)!).length
        
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
        
        // Update selected date components
        dateComponents!.day = selectedCell!.dayLabel.text!.toInt()!
        dateComponents = getNewDateComponents(dateComponents!)
        
        let selectedDate = calendar.dateFromComponents(dateComponents!)!
        
        NSNotificationCenter.defaultCenter().postNotificationName("SelectedDateChanged", object: self, userInfo: ["Date": selectedDate])
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
    }
    
    /**
        Called on deselection of day cell in month.
    */
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        deselectSelectedCell()
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
            
            // If no cell has been selected and the cell's day matches the date components day, select the cell.
            if selectedCell == nil {
                let dayToSelect = dateComponents!.day
                
                if day == dayToSelect {
                    selectCell(cell)
                }
            }
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
        return cellsInMonth
    }
    
    /**
        Create header with weekday labels.
    */
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "MonthItemCollectionHeaderView", forIndexPath: indexPath) as! MonthItemCollectionHeaderView
        // Create constraints to space labels properly
        header.createConstraints()
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MonthItemCollectionViewController: UICollectionViewDelegateFlowLayout {
    /**
        Determines size of one cell.
        
        Note: due to the iOS Simulator, the rightmost cell is cut off slightly because it has a scrollbar. The sizing is correct on an actual device.
    */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width /
            CGFloat(daysInWeek),
                height: (collectionView.bounds.size.height - headerHeight) /
                    CGFloat(rowsInMonth))
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(collectionView.frame.size.width, headerHeight)
    }
}