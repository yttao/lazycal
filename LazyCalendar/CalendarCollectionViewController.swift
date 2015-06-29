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
    private let reuseIdentifier = "DayCell"
    
    // TODO: move this to a Calendar class
    private var daysInMonth = [Int]()
    
    // 7 days in a week
    private let numDaysInWeek = 7
    // 5 weeks (overlapping with weeks in adjacent months) in a month
    private let numWeeksInMonth = 5
    // Max number of cells
    private let numCellsInMonth = 35
    
    private var monthStartDay = 0
    private var currentDay = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var calendar = NSCalendar.currentCalendar()
        
        // Find num days in month
        var today = NSDate()
        let numDays = calendar.rangeOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.CalendarUnitMonth, forDate: today).length
        for (var i = 1; i <= numDays; i++) {
            daysInMonth.append(i)
        }
        
        // Get start weekday for month
        var weekdayComponents = calendar.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: today)
        weekdayComponents.day = 1
        monthStartDay = weekdayComponents.weekday - 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    // Returns number of items in month
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return numCellsInMonth
    }

    // Makes cell with day number shown
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CalendarCollectionViewCell
        
        let afterMonthStartDay = indexPath.row >= monthStartDay
        let beforeMonthEndDay = indexPath.row < (daysInMonth.count + monthStartDay)
        if (afterMonthStartDay && beforeMonthEndDay) {
            let day = daysInMonth[currentDay]

            cell.dayLabel.text = "\(day)"
            currentDay++
        }
        else {
            cell.dayLabel.text = "x"
        }
    
        return cell
    }
    
    // Blue background on selecting day
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let day = daysInMonth[indexPath.row]
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}

// Handles sizing of cells
extension CalendarCollectionViewController: UICollectionViewDelegateFlowLayout {
    // Determines size of one cell
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 7, height: collectionView.frame.size.height / 10) //collectionView.frame.size.height / 5)
    }
    
    // Determines spacing between cells (none)
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }
}