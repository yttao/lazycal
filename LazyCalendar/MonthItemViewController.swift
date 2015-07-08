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
    @IBOutlet weak var monthItemTableView: UITableView?
    
    // Used to order months
    var dateIndex: NSDate?
    
    private let backgroundColor = UIColor(red: 125, green: 255, blue: 125, alpha: 0)
    private let selectedColor = UIColor.whiteColor()
    
    private let reuseIdentifier = "DayCell"
    
    private var daysInMonth = [Int]()
    
    private var calendar: NSCalendar?
    
    private var selectedCell: UICollectionViewCell?
    
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
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        //self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthItemCollectionView.delegate = self
        monthItemCollectionView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
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
        
        self.navigationItem.title = String(dateComponents.month)
    }
    
    func clearSelected() {
        if selectedCell != nil {
            selectedCell!.backgroundColor = backgroundColor
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numCellsInMonth
    }
    
    // Makes cell with day number shown
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
            cell.dayLabel.text = nil
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("Selected at \(indexPath.row)")
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
            //println(selectedCell!.description)
            selectedComponents.day = (selectedCell as! CalendarCollectionViewCell).dayLabel.text!.toInt()!
            let selectedDate = calendar!.dateFromComponents(selectedComponents)
            ShowEvents(selectedDate!)
        }
    }
    
    func ShowEvents(date: NSDate) {
        //println(date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// Handles sizing of cells
extension MonthItemViewController: UICollectionViewDelegateFlowLayout {
    // Determines size of one cell
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        /*println("Collection view width: \(collectionView.frame.size.width)")
        println("Collection view height: \(collectionView.frame.size.height)")
        println("Total view width: \(view.frame.size.width)")
        println("Total height:  \(view.frame.size.height)")*/
        
        return CGSize(width: collectionView.frame.size.width / 7, height: (collectionView.frame.size.height) / 6)
    }
    
    // Determines spacing between cells (none)
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
}