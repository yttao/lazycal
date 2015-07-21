//
//  MonthItemPageViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/21/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class MonthItemPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var customDelegate: MonthItemPageViewControllerDelegate?
    
    private var calendar: NSCalendar?
    // Keeps track of current date view
    var dateComponents: NSDateComponents?
    // Calendar units to keep track of
    private let units = NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth |
        NSCalendarUnit.CalendarUnitYear
    
    var monthItemViewController: MonthItemViewController?
    var currentViewController: MonthItemCollectionViewController? {
        didSet {
            customDelegate?.monthItemPageViewControllerDidChangeCurrentViewController(currentViewController!)
        }
    }
    
    // Initialize calendar, start date, and date components for start date
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        calendar = NSCalendar.currentCalendar()
        dateComponents = calendar!.components(units, fromDate: NSDate())
    }
    
    
    // On load, create page view controller with initial view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        initializePageViewController()
    }
    
    
    // Moves date components to the next month
    func goToNextMonth() {
        dateComponents!.month++
        dateComponents!.day = 1
        dateComponents = getNewDateComponents(dateComponents!)
    }
    
    
    // Moves date components to the previous month
    func goToPrevMonth() {
        dateComponents!.month--
        dateComponents!.day = 1
        dateComponents = getNewDateComponents(dateComponents!)
    }
    
    
    // Recalculates components after fields have been changed in components
    func getNewDateComponents(components: NSDateComponents) -> NSDateComponents {
        let newDate = calendar!.dateFromComponents(components)
        return calendar!.components(units, fromDate: newDate!)
    }
    
    
    // Creates first page view controller with month as this month
    private func initializePageViewController() {
        // Make first view controller
        let firstController = getMonthItemCollectionViewController(dateComponents!)
        
        currentViewController = firstController
        
        let startingViewController = [firstController]
        // Set initial view controller
        self.setViewControllers(startingViewController, direction: UIPageViewControllerNavigationDirection.Forward , animated: false, completion: nil)
    }
    
    
    // Previous view controller is for previous month
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        // Create components for previous month
        let components = dateComponents!.copy() as! NSDateComponents
        components.month--
        components.day = 1
        let newComponents = getNewDateComponents(components)
        
        return getMonthItemCollectionViewController(newComponents)
    }
    
    
    // Next view controller is for next month
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        // Create components for next month
        let components = dateComponents!.copy() as! NSDateComponents
        components.month++
        components.day = 1
        let newComponents = getNewDateComponents(components)
        
        return getMonthItemCollectionViewController(newComponents)
    }

    
    /*
    @brief After scrolling, switch months.
    @discussion On month switch, change date components to reflect current month and clear selections from past months.
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
    
    
    /*
    @brief Creates month view controller.
    @param components The date components used to construct the month and load month data.
    @return MonthItemCollectionViewController The collection view controller that displays the month view.
    */
    private func getMonthItemCollectionViewController(components: NSDateComponents) -> MonthItemCollectionViewController {
        // Instantiate copy of prefab view controller
        let monthItemCollectionViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MonthItemCollectionViewController") as! MonthItemCollectionViewController
        // Load data
        monthItemCollectionViewController.loadData(components, delegate: monthItemViewController!)
        
        return monthItemCollectionViewController
    }
}


protocol MonthItemPageViewControllerDelegate {
    func monthItemPageViewControllerDidChangeCurrentViewController(monthItemCollectionViewController: MonthItemCollectionViewController)
}
