//
//  MonthItemPageViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/21/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class MonthItemPageViewController: UIPageViewController {
    
    var customDelegate: MonthItemPageViewControllerDelegate?
    
    private let calendar = NSCalendar.currentCalendar()
    // Keeps track of current date view
    var dateComponents: NSDateComponents
    // Calendar units to keep track of
    private let units = NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth |
        NSCalendarUnit.CalendarUnitYear
    
    var monthItemViewController: MonthItemViewController?
    
    private var currentViewController: MonthItemCollectionViewController? {
        didSet {
            customDelegate?.monthItemPageViewControllerDidChangeCurrentViewController(currentViewController!)
        }
    }
    
    /**
        Initialize date components for start date.
    */
    required init(coder aDecoder: NSCoder) {
        dateComponents = calendar.components(units, fromDate: NSDate())
        
        super.init(coder: aDecoder)
        // calendar = NSCalendar.currentCalendar()
        //dateComponents = calendar.components(units, fromDate: NSDate())
    }
    
    
    // On load, create page view controller with initial view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        initializePageViewController()
    }
    
    /**
        Creates first page view controller with month as this month
    */
    private func initializePageViewController() {
        // Make first view controller
        let firstController = getMonthItemCollectionViewController(dateComponents)
        
        currentViewController = firstController
        
        let startingViewController = [firstController]
        self.setViewControllers(startingViewController, direction: UIPageViewControllerNavigationDirection.Forward , animated: false, completion: nil)
    }
    
    /**
        Update information to progress to the next month.
    */
    func goToNextMonth() {
        dateComponents.month++
        dateComponents.day = 1
        dateComponents = getNewDateComponents(dateComponents)
    }
    
    
    /**
        Update information to return to the previous month.
    */
    func goToPrevMonth() {
        dateComponents.month--
        dateComponents.day = 1
        dateComponents = getNewDateComponents(dateComponents)
    }
    
    
    /**
        Recalculates date components after date component fields have been modified.
    
        :param: components The date components to be updated.
    
        :returns: The new date components.
    */
    func getNewDateComponents(components: NSDateComponents) -> NSDateComponents {
        let newDate = calendar.dateFromComponents(components)
        return calendar.components(units, fromDate: newDate!)
    }
    
    /**
        Creates a new `MonthItemCollectionViewController` for a month view.
    
        :param: components The date components used to construct the month and load month data.
    
        :returns: The `MonthItemCollectionViewController` that displays the month view.
    */
    private func getMonthItemCollectionViewController(components: NSDateComponents) -> MonthItemCollectionViewController {
        // Instantiate copy of prefab view controller
        let monthItemCollectionViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MonthItemCollectionViewController") as! MonthItemCollectionViewController
        // Load data
        monthItemCollectionViewController.loadData(components)
        monthItemCollectionViewController.delegate = monthItemViewController
        
        return monthItemCollectionViewController
    }
}

// MARK: - UIPageViewControllerDelegate
extension MonthItemPageViewController: UIPageViewControllerDelegate {
    /**
        After scrolling, switch months.
    
        On month switch, change date components to reflect current month and clear selections from past months.
    */
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        let newMonth = pageViewController.viewControllers.first! as! MonthItemCollectionViewController
        let oldMonth = previousViewControllers.first! as! MonthItemCollectionViewController
        
        currentViewController = newMonth
        
        // Change current month based on whether you went to previous or next month
        if (oldMonth.dateIndex!.compare(newMonth.dateIndex!) ==
            NSComparisonResult.OrderedAscending) {
                goToNextMonth()
                oldMonth.clearSelected()
        }
        else if (oldMonth.dateIndex!.compare(newMonth.dateIndex!) ==
            NSComparisonResult.OrderedDescending) {
                goToPrevMonth()
                oldMonth.clearSelected()
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension MonthItemPageViewController: UIPageViewControllerDataSource {
    /**
        Previous view controller is for previous month.
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        // Create components for previous month
        let components = dateComponents.copy() as! NSDateComponents
        components.month--
        components.day = 1
        let newComponents = getNewDateComponents(components)
        
        return getMonthItemCollectionViewController(newComponents)
    }
    
    /**
        Next view controller is for next month.
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        // Create components for next month
        let components = dateComponents.copy() as! NSDateComponents
        components.month++
        components.day = 1
        let newComponents = getNewDateComponents(components)
        
        return getMonthItemCollectionViewController(newComponents)
    }
}


/**
    Delegate protocol for `MonthItemPageViewController`.
*/
protocol MonthItemPageViewControllerDelegate {
    /**
        Informs the delegate that the current `MonthItemPageViewController` changed the current controller.
    
        :param: monthItemCollectionViewController The new `MonthItemCollectionViewController` that is presented.
    */
    func monthItemPageViewControllerDidChangeCurrentViewController(monthItemCollectionViewController: MonthItemCollectionViewController)
}
