//
//  ViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 6/29/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private var pageViewController: UIPageViewController?

    private var calendar: NSCalendar?
    // Keeps track of current date view
    private var dateComponents: NSDateComponents?
    // Calendar units to keep track of
    private let units = NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth |
        NSCalendarUnit.CalendarUnitYear
    
    // Initialize calendar, start date, and date components for start date
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        calendar = NSCalendar.currentCalendar()
        dateComponents = calendar!.components(units, fromDate: NSDate())
    }
    
    // On load, create page view controller with initial view
    override func viewDidLoad() {
        super.viewDidLoad()
        createPageViewController()
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
        var newDate = calendar!.dateFromComponents(components)
        return calendar!.components(units, fromDate: newDate!)
    }
    
    // Creates first page view controller with month as this month
    private func createPageViewController() {
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("MonthPageViewController") as! UIPageViewController
        // Set data source and delegate
        pageController.dataSource = self
        pageController.delegate = self
        // Make first view controller
        let firstController = getMonthItemViewController(dateComponents!)!
        let startingViewController = [firstController]
        // Set initial view controller
        pageController.setViewControllers(startingViewController, direction: UIPageViewControllerNavigationDirection.Forward , animated: false, completion: nil)

        pageViewController = pageController
        self.addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        /*pageViewController!.didMoveToParentViewController(self)*/
    }

    // Previous view controller is for previous month
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        // Create components for previous month
        let components = dateComponents!.copy() as! NSDateComponents
        components.month--
        let newComponents = getNewDateComponents(components)

        return getMonthItemViewController(newComponents)
    }
    
    // Next view controller is for next month
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        // Create components for next month
        let components = dateComponents!.copy() as! NSDateComponents
        components.month++
        let newComponents = getNewDateComponents(components)
        
        return getMonthItemViewController(newComponents)
    }
    
    // On month switch, change date components to reflect current month and clear selections from past months.
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        let newMonth = pageViewController.viewControllers.first!.childViewControllers.first! as! MonthItemViewController
        let oldMonth = previousViewControllers.first!.childViewControllers.first! as! MonthItemViewController
        
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
    
    // Creates month view controller
    private func getMonthItemViewController(components: NSDateComponents) -> MonthItemNavigationController? {
        // Instantiate copy of prefab view controller
        let monthItemNavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("MonthItemNavigationController") as! MonthItemNavigationController
        // Load data
        monthItemNavigationController.loadData(calendar!, components: components)

        return monthItemNavigationController
    }
}


