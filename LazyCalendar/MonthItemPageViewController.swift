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
    // Calendar units to keep track of
    private let units: NSCalendarUnit = .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear
    
    /**
        Initialize date components for start date.
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
        On load, call `initializePageViewController` to set up initial view controller.
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
        let firstViewController = getMonthItemCollectionViewController(calendar.components(units, fromDate: NSDate()))

        setViewControllers([firstViewController], direction: UIPageViewControllerNavigationDirection.Forward , animated: false, completion: nil)
        
        NSNotificationCenter.defaultCenter().postNotificationName("MonthChanged", object: self, userInfo: ["ViewController": firstViewController])
    }
    
    // MARK: - Methods for creating new view controllers.
    
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
    // MARK: - Methods for handling page view transitions.
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        let oldMonth = previousViewControllers.first as! MonthItemCollectionViewController
        let currentMonth = pageViewController.viewControllers.first as! MonthItemCollectionViewController
        
        NSNotificationCenter.defaultCenter().postNotificationName("MonthChanged", object: self, userInfo: ["ViewController": currentMonth])
        
        if oldMonth != currentMonth {
            oldMonth.clearSelected()
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension MonthItemPageViewController: UIPageViewControllerDataSource {
    // MARK: - Methods for determining the neighboring view controllers.
    
    /**
        The previous view controller is for the previous month.
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        // Create date components for previous month.
        let month = viewController as! MonthItemCollectionViewController
        let dateIndex = month.dateIndex
        let components = calendar.components(units, fromDate: dateIndex)
        components.month--
        
        // Return previous month view controller.
        return getMonthItemCollectionViewController(components)
    }
    
    /**
        The next view controller is for the next month.
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        // Create date components for next month.
        let month = viewController as! MonthItemCollectionViewController
        let dateIndex = month.dateIndex
        let components = calendar.components(units, fromDate: dateIndex)
        components.month++
        
        // Return next month view controller.
        return getMonthItemCollectionViewController(components)
    }
}