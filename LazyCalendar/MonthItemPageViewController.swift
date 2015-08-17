//
//  MonthItemPageViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/21/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class MonthItemPageViewController: UIPageViewController {
    private let calendar = NSCalendar.currentCalendar()
    // Keeps track of current date view
    private var dateComponents: NSDateComponents
    // Calendar units to keep track of
    private let units: NSCalendarUnit = .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear
    
    /**
        Initialize date components for start date.
    */
    required init(coder aDecoder: NSCoder) {
        dateComponents = calendar.components(units, fromDate: NSDate())
        
        super.init(coder: aDecoder)
    }
    
    /**
        On load, create page view controller with initial view
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        initializePageViewController()
    }
    
    /**
        Creates first view controller with this month as the first month to show.
    
        
    */
    private func initializePageViewController() {
        // Make first view controller
        let firstViewController = getMonthItemCollectionViewController(dateComponents)

        setViewControllers([firstViewController], direction: UIPageViewControllerNavigationDirection.Forward , animated: false, completion: nil)
        
        NSNotificationCenter.defaultCenter().postNotificationName("MonthChanged", object: self, userInfo: ["ViewController": firstViewController])
    }
    
    /**
        Update information to progress to the next month.
    */
    func goToNextMonth() {
        dateComponents.month++
        dateComponents.day = 1
        getNewDateComponents(&dateComponents)
    }
    
    
    /**
        Update information to return to the previous month.
    */
    func goToPrevMonth() {
        dateComponents.month--
        dateComponents.day = 1
        getNewDateComponents(&dateComponents)
    }
    
    
    /**
        Recalculates date components after date component fields have been modified.
    
        :param: components The date components to be updated.
    
        :returns: The new date components.
    */
    func getNewDateComponents(inout components: NSDateComponents) {
        let newDate = calendar.dateFromComponents(components)
        components = calendar.components(units, fromDate: newDate!)
    }
    
    /**
        Creates a new `MonthItemCollectionViewController` for a month view.
    
        :param: components The date components used to construct the month and load month data.
    
        :returns: The `MonthItemCollectionViewController` that displays the month view.
    */
    private func getMonthItemCollectionViewController(components: NSDateComponents) -> MonthItemCollectionViewController {
        // Instantiate copy of view controller
        let monthItemCollectionViewController = storyboard!.instantiateViewControllerWithIdentifier("MonthItemCollectionViewController") as! MonthItemCollectionViewController
        // Load data
        monthItemCollectionViewController.loadData(components)
        
        return monthItemCollectionViewController
    }
}

// MARK: - UIPageViewControllerDelegate
extension MonthItemPageViewController: UIPageViewControllerDelegate {
    /**
        When scrolling to the next month, switch months to the new month view.
    
        On month switch, change date components to reflect current month and clear selections from past months.
    */
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
        let oldMonth = pageViewController.viewControllers.first! as! MonthItemCollectionViewController
        let newMonth = pendingViewControllers.first as! MonthItemCollectionViewController
        
        NSNotificationCenter.defaultCenter().postNotificationName("MonthChanged", object: self, userInfo: ["ViewController": newMonth])
        
        // Change current month based on whether you went to previous or next month
        if (oldMonth.dateIndex!.compare(newMonth.dateIndex!) == .OrderedAscending) {
                goToNextMonth()
        }
        else if (oldMonth.dateIndex!.compare(newMonth.dateIndex!) == .OrderedDescending) {
                goToPrevMonth()
        }
        oldMonth.clearSelected()
    }
}

// MARK: - UIPageViewControllerDataSource
extension MonthItemPageViewController: UIPageViewControllerDataSource {
    /**
        Previous view controller is for previous month.
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        // Create components for previous month
        var components = dateComponents.copy() as! NSDateComponents
        components.month--
        components.day = 1
        getNewDateComponents(&components)
        
        return getMonthItemCollectionViewController(components)
    }
    
    /**
        Next view controller is for next month.
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        // Create components for next month
        var components = dateComponents.copy() as! NSDateComponents
        components.month++
        components.day = 1
        getNewDateComponents(&components)
        
        return getMonthItemCollectionViewController(components)
    }
}