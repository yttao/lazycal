//
//  MonthItemCollectionViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/15/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class MonthItemCollectionViewController: UICollectionViewController {
    var dateIndex: NSDate!
    var dateComponents: NSDateComponents?
    
    // 7 days in a week
    private let daysInWeek = 7
    // Max number of rows that can be displayed, 1 row per week
    private let rowsInMonth = 6
    // Max number of cells (7 days * 6 rows)
    private let cellsInMonth = 42
    
    // Colors used
    private var deselectedColor: UIColor!
    private var selectedColor: UIColor!
    
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
    private var selectedIndexPath: NSIndexPath?
    
    // Start weekday
    private var monthStartWeekday = 0
    // Keeps track of current date view components
    
    // Size of header
    private let headerHeight: CGFloat = 30
    
    // Animation time for selection/deselection
    var animationTime = 0.2
    
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
        
        selectedColor = UIColor(red: 0, green: 0.8, blue: 0.2, alpha: 0.5)
        deselectedColor = UIColor.clearColor()
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
        let dateIndexComponents = components.copy()  as! NSDateComponents
        dateIndexComponents.day = 1
        dateIndex = calendar.dateFromComponents(dateIndexComponents)
        
        let numDays = calendar.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: calendar.dateFromComponents(components)!).length
        
        for i in (monthStartWeekday - 1)..<(numDays + (monthStartWeekday - 1)) {
            daysInMonth[i] = i - (monthStartWeekday - 2)
        }
    }
    
    /**
        Resets collection view selection by calling `deselectSelectedCell()` to deselect the currently selected cell and setting date components to the first day in the month.
    */
    func clearSelected() {
        deselectSelectedCell()
        dateComponents!.day = 1
    }
    
    /**
        Selects the specified cell.
    
        :param: cell The cell to select.
    */
    func selectCell(cell: CalendarCollectionViewCell, indexPath: NSIndexPath) {
        // Add circle mask if cell doesn't have one.
        if cell.layer.mask == nil {
            let circleLayer = CAShapeLayer(layer: cell.layer)
            let circlePath = UIBezierPath(ovalInRect: cell.bounds)
            circleLayer.path = circlePath.CGPath
            cell.layer.mask = circleLayer
        }
        
        // Color cell with animation.
        UIView.animateWithDuration(animationTime, animations: {
            cell.backgroundColor = self.selectedColor
        })
        
        // Select cell.
        selectedCell = cell
        selectedIndexPath = indexPath
        
        // Update selected date components
        dateComponents!.day = selectedCell!.dayLabel.text!.toInt()!
        
        let selectedDate = calendar.dateFromComponents(dateComponents!)!
        
        NSNotificationCenter.defaultCenter().postNotificationName("SelectedDateChanged", object: self, userInfo: ["Date": selectedDate])
    }
    
    /**
        Deselects the currently selected cell.
    */
    func deselectSelectedCell() {
        if let cell = selectedCell {
            // Decolor cell with animation.
            UIView.animateWithDuration(animationTime, animations: {
                cell.backgroundColor = self.deselectedColor
            })
            
            // Deselect cell.
            selectedCell = nil
            selectedIndexPath = nil
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
}

// MARK: - UICollectionViewDelegate
extension MonthItemCollectionViewController: UICollectionViewDelegate {
    /**
        Day cells are selectable only if they have a valid number in them.
    */
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CalendarCollectionViewCell
        
        // If cell is same as already selected cell, don't reselect.
        if cell == selectedCell {
            return false
        }
        
        // Check for valid number.
        if cell.dayLabel.text?.toInt() != nil {
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
        selectCell(cell, indexPath: indexPath)
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
            
            /*if selectedCell == nil && day == dateComponents!.day {
                let indexPath = NSIndexPath(forItem: dateComponents!.day + monthStartWeekday - 2, inSection: 0)
                selectCell(cell, indexPath: indexPath)
            }*/
        }
        else {
            cell.dayLabel.text = nil
        }
        
        return cell
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
        Determines number of items in month.
    */
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellsInMonth
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! CalendarCollectionViewCell
        if selectedCell == nil && cell.dayLabel.text?.toInt() == dateComponents!.day {
            selectCell(cell, indexPath: indexPath)
        }
    }
    
    /**
        Create header with weekday labels.
    */
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "MonthItemCollectionHeaderView", forIndexPath: indexPath) as! MonthItemCollectionHeaderView
        // Create constraints to space labels properly and borders for separation.
        header.addConstraints()
        //header.addBorders()
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MonthItemCollectionViewController: UICollectionViewDelegateFlowLayout {
    /**
        Determines size of one cell.
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