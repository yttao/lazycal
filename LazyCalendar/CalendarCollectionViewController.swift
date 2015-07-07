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
    
    private let reuseIdentifier = "DayCell"
    
    private var daysInMonth = [Int]()
    
    private var calendar: NSCalendar?
    
    private var selectedCell: UICollectionViewCell? {
        didSet {
            let selected = selectedCell as! CalendarCollectionViewCell
            let selectedComponents = calendar!.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: dateIndex!)
            selectedComponents.day = (selectedCell as! CalendarCollectionViewCell).dayLabel.text!.toInt()!
            let selectedDate = calendar!.dateFromComponents(selectedComponents)
            ShowEvents(selectedDate!)
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
        
        let numDays = self.calendar!.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate:
            self.calendar!.dateFromComponents(self.dateComponents!)!).length
        for (var i = 1; i <= numDays; i++) {
            daysInMonth.append(i)
        }
    }
    
    /*required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Load calendar and today's date at start
        calendar = NSCalendar.currentCalendar()
        today = NSDate()

        // Get start month (1-12), and start year
        dateComponents = calendar!.components(units, fromDate: today!)
        // Find first weekday of month
        monthStartWeekday = getMonthStartWeekday(dateComponents!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numDays = calendar!.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate:
            calendar!.dateFromComponents(dateComponents!)!).length
        for (var i = 1; i <= numDays; i++) {
            daysInMonth.append(i)
        }
        
        addGestures()
    }
    
    // Adds left and right swipe gestures
    func addGestures() {
        // On swipe left, go to the next month view
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "goToNextMonth:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        view.addGestureRecognizer(swipeLeft)
        
        // On swipe right, go to the previous month view
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "goToPrevMonth:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(swipeRight)
    }
    
    func goToNextMonth(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            dateComponents!.month++
            dateComponents!.day = 1
            currentDay = 1
            dateComponents = getNewDateComponents(dateComponents!)
            monthStartWeekday = getMonthStartWeekday(dateComponents!)
            println("Start weekday for month \(dateComponents!.month) is \(monthStartWeekday)")
            println(dateComponents!.description)
        }
    }
    
    func goToPrevMonth(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            dateComponents!.month--
            dateComponents!.day = 1
            currentDay = 1
            dateComponents = getNewDateComponents(dateComponents!)
            monthStartWeekday = getMonthStartWeekday(dateComponents!)
            println("Start weekday for month \(dateComponents!.month) is \(monthStartWeekday)")
            println(dateComponents!.description)
        }
    }*/
    
    // Gets the first weekday of the month
    func getMonthStartWeekday(components: NSDateComponents) -> Int {
        var componentsCopy = components.copy() as! NSDateComponents
        componentsCopy.day = 1
        var startMonthDate = calendar!.dateFromComponents(componentsCopy)
        var startMonthDateComponents = calendar!.components(.CalendarUnitWeekday, fromDate: startMonthDate!)
        return startMonthDateComponents.weekday
    }
    
    /*// Recalculates components after fields have been changed in components
    func getNewDateComponents(components: NSDateComponents) -> NSDateComponents {
        var newDate = calendar!.dateFromComponents(components)
        return calendar!.components(units, fromDate: newDate!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }*/
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
            case UICollectionElementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "MonthItemHeaderView", forIndexPath: indexPath) as! MonthItemHeaderView
                println("Is month item header view")
                headerView.headerLabel.text = "\(dateComponents!.month)"
                return headerView
            default:
                assert(false, "Unexpected element kind")
        }
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
            cell.dayLabel.text = ""
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("Selected at \(indexPath.row)")
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CalendarCollectionViewCell
        if cell.dayLabel.text != "" && !(cell == selectedCell) && selectedCell != nil {
            selectedCell!.backgroundColor = UIColor.whiteColor()
            cell.backgroundColor = UIColor.lightGrayColor()
            selectedCell = cell
        }
        else if selectedCell == nil && cell.dayLabel.text != "" {
            cell.backgroundColor = UIColor.lightGrayColor()
            selectedCell = cell
        }
    }
    
    func ShowEvents(date: NSDate) {
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