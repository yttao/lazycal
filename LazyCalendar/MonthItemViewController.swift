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

    // Used to identify month
    var dateIndex: NSDate?
    
    // 7 days in a week
    private static let numDaysInWeek = 7
    // Max number of weeks that can be displayed
    private static let numWeeksInMonth = 6
    // Max number of cells (7 days * 6 rows)
    private static let numCellsInMonth = 42
    
    // Colors used
    private let backgroundColor = UIColor(red: 125, green: 255, blue: 125, alpha: 0)
    private let selectedColor = UIColor.whiteColor()
    
    private let reuseIdentifier = "DayCell"
    
    // NSCalendarUnits to keep track of
    private let units = NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth |
        NSCalendarUnit.CalendarUnitYear
    
    private var daysInMonth = [Int?](count: MonthItemViewController.numCellsInMonth, repeatedValue: nil)
    private var calendar: NSCalendar?
    private var selectedCell: UICollectionViewCell?
    
    private var monthStartWeekday = 0
    // Keeps track of current date view
    private var dateComponents: NSDateComponents?
    
    @IBAction func addEvent(sender: AnyObject) {
        
    }
    
    @IBAction func cancelEvent(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func saveEvent(segue: UIStoryboardSegue) {
    
    }

    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthItemCollectionView.delegate = self
        monthItemCollectionView.dataSource = self
        
        let heightConstraint = NSLayoutConstraint(item: monthItemCollectionView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: CGFloat(view.frame.size.height / 2))
        monthItemCollectionView.addConstraint(heightConstraint)
    }

    
    func loadData(calendar: NSCalendar, dateComponents: NSDateComponents) {
        self.calendar = calendar
        self.dateComponents = dateComponents
        
        monthStartWeekday = getMonthStartWeekday(self.dateComponents!)
        
        dateIndex = calendar.dateFromComponents(self.dateComponents!)
        
        let numDays = self.calendar!.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: self.calendar!.dateFromComponents(self.dateComponents!)!).length
        
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
    
    // Clears current selection
    func clearSelected() {
        if selectedCell != nil {
            selectedCell!.backgroundColor = backgroundColor
        }
        
        selectedCell = nil
    }
    
    // Gets the first weekday of the month
    func getMonthStartWeekday(components: NSDateComponents) -> Int {
        let componentsCopy = components.copy() as! NSDateComponents
        componentsCopy.day = 1
        let startMonthDate = calendar!.dateFromComponents(componentsCopy)
        let startMonthDateComponents = calendar!.components(.CalendarUnitWeekday, fromDate: startMonthDate!)
        return startMonthDateComponents.weekday
    }
    
    // Determines number of items in month
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MonthItemViewController.numCellsInMonth
    }
    
    // Makes cell with day number shown
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CalendarCollectionViewCell
        
        // Set day number for cell
        if let day = daysInMonth[indexPath.row] {
            
            cell.dayLabel.text = String(day)
        }
        else {
            cell.dayLabel.text = nil
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CalendarCollectionViewCell
        if cell.dayLabel.text != nil && !(cell == selectedCell) && selectedCell != nil {
            selectedCell!.backgroundColor = backgroundColor
            cell.backgroundColor = selectedColor
            selectedCell = cell
            
            let selectedComponents = calendar!.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: dateIndex!)
            selectedComponents.day = (selectedCell as! CalendarCollectionViewCell).dayLabel.text!.toInt()!
            let selectedDate = calendar!.dateFromComponents(selectedComponents)
            ShowEvents(selectedDate!)
        }
        else if selectedCell == nil && cell.dayLabel.text != nil {
            cell.backgroundColor = selectedColor
            selectedCell = cell
            
            let selectedComponents = calendar!.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: dateIndex!)
            selectedComponents.day = (selectedCell as! CalendarCollectionViewCell).dayLabel.text!.toInt()!
            let selectedDate = calendar!.dateFromComponents(selectedComponents)
            ShowEvents(selectedDate!)
        }
    }
    
    // Shows events for a date
    func ShowEvents(date: NSDate) {
        println(date)
    }
}

// Handles sizing of cells
extension MonthItemViewController: UICollectionViewDelegateFlowLayout {
    // Determines size of one cell
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //println(collectionView.frame.size.height)
        //println(view.frame.size.height)
        
        return CGSize(width: collectionView.frame.size.width /
            CGFloat(MonthItemViewController.numDaysInWeek),
            height: (collectionView.frame.size.height) /
                CGFloat(MonthItemViewController.numWeeksInMonth))
    }
    
    // Determines spacing between cells
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    // Determines sizing between sections
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    // Determines inset for section
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
}