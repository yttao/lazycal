//
//  CalendarCollectionViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 6/29/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

// Controller for view of one month
class CalendarCollectionViewController: UICollectionViewController, UICollectionViewDataSource {
    // Used to order months
    var dateIndex: NSDate?
    
    private let backgroundColor = UIColor.blackColor()
    private let selectedColor = UIColor.grayColor()
    
    private let reuseIdentifier = "DayCell"
    
    private var daysInMonth = [Int?]()
    
    private var calendar: NSCalendar?
    
    private var selectedCell: UICollectionViewCell? {
        didSet {
            if let selected = selectedCell as? CalendarCollectionViewCell {
                let selectedComponents = calendar!.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: dateIndex!)
                selectedComponents.day = selected.dayLabel.text!.toInt()!
                //let selectedComponents = dateComponents!
                let selectedDate = calendar!.dateFromComponents(selectedComponents)
                ShowEvents(selectedDate!)
            }
        }
    }
    
    // 7 days in a week
    private let numDaysInWeek = 7
    // 5 weeks (overlapping with weeks in adjacent months) in a month
    private let numWeeksInMonth = 5
    // Max number of cells
    private let numCellsInMonth = 42
    
    private var monthStartWeekday = 0
    private var currentDay = 1
    // Keeps track of current date view
    private var dateComponents: NSDateComponents?
    
    // NSCalendarUnits to keep track of
    private let units = NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth |
        NSCalendarUnit.CalendarUnitYear
    
    func loadData(calendar: NSCalendar, today: NSDate, dateComponents: NSDateComponents) {
        self.calendar = calendar
        self.dateComponents = dateComponents
        monthStartWeekday = getMonthStartWeekday(self.dateComponents!)
        dateIndex = calendar.dateFromComponents(self.dateComponents!)
        
        let numDays = self.calendar!.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: self.calendar!.dateFromComponents(self.dateComponents!)!).length
        daysInMonth.append(nil)
        for (var i = 1; i <= numDays; i++) {
            daysInMonth.append(i)
        }
        
        self.navigationItem.title = String(dateComponents.month)
    }
    
    func clearSelected() {
        if selectedCell != nil {
            selectedCell!.backgroundColor = self.backgroundColor
        }
        
        selectedCell = nil
    }
    
    // Gets the first weekday of the month
    func getMonthStartWeekday(components: NSDateComponents) -> Int {
        var componentsCopy = components.copy() as! NSDateComponents
        componentsCopy.day = 1
        var startMonthDate = calendar!.dateFromComponents(componentsCopy)
        var startMonthDateComponents = calendar!.components(.CalendarUnitWeekday, fromDate: startMonthDate!)
        return startMonthDateComponents.weekday
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    // Returns number of items in month
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numCellsInMonth
    }

    // Makes cell with day number shown
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CalendarCollectionViewCell
        
        // Check if cell is within the bounds of correct dates for that month.
        let afterMonthStartDay = indexPath.row >= (monthStartWeekday - 1)
        let beforeMonthEndDay = indexPath.row < (daysInMonth.count + (monthStartWeekday - 1))
        
        if (afterMonthStartDay && beforeMonthEndDay) {
            // Set text
            let day = daysInMonth[currentDay - 1]

            cell.dayLabel.text = "\(day)"
            currentDay++
        }
        else {
            cell.dayLabel.text = "x"
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("Selected at \(indexPath.row)")
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CalendarCollectionViewCell
        if cell.dayLabel.text != "" && !(cell == selectedCell) && selectedCell != nil {
            selectedCell!.backgroundColor = backgroundColor
            cell.backgroundColor = selectedColor
            selectedCell = cell
        }
        else if selectedCell == nil && cell.dayLabel.text != "" {
            cell.backgroundColor = selectedColor
            selectedCell = cell
        }
    }
    
    func ShowEvents(date: NSDate) {
        println("***")
        println(date)
    }
}

// Handles sizing of cells
extension CalendarCollectionViewController: UICollectionViewDelegateFlowLayout {
    // Determines size of one cell
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 7, height: collectionView.frame.size.height / 12) //collectionView.frame.size.height / 5)
    }
    
    // Determines spacing between cells (none)
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }
}
