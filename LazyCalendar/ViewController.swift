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
    private var today: NSDate?
    // Keeps track of current date view
    private var dateComponents: NSDateComponents?
    // NSCalendarUnits to keep track of
    private let units = NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth |
        NSCalendarUnit.CalendarUnitYear
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        calendar = NSCalendar.currentCalendar()
        today = NSDate()
        dateComponents = calendar!.components(units, fromDate: today!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPageViewController()
    }
    
    func goToNextMonth() {
        dateComponents!.month++
        dateComponents!.day = 1
        dateComponents = getNewDateComponents(dateComponents!)
    }
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Creates first page view controller
    private func createPageViewController() {
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("MonthPageViewController") as! UIPageViewController
        // Set data source and delegate
        pageController.dataSource = self
        pageController.delegate = self
        // Make first view controller
        let firstController = getMonthController(dateComponents!)!
        let startingViewController = [firstController]
        // Set initial view controller
        pageController.setViewControllers(startingViewController, direction: UIPageViewControllerNavigationDirection.Forward , animated: false, completion: nil)

        pageViewController = pageController
        self.addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        /*pageViewController!.didMoveToParentViewController(self)*/
    }
    
    // Function to handle direction change - call goToNextMonth/goToPrevMonth twice instead of once

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let components = dateComponents!.copy() as! NSDateComponents
        components.month--
        let newComponents = getNewDateComponents(components)

        return getMonthController(newComponents)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let components = dateComponents!.copy() as! NSDateComponents
        components.month++
        let newComponents = getNewDateComponents(components)
        
        return getMonthController(newComponents)
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        let newMonth = pageViewController.viewControllers[0].childViewControllers[0] as! MonthItemViewController
        let oldMonth = previousViewControllers[0].childViewControllers[0] as! MonthItemViewController
        
        // Change current month
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
    private func getMonthController(components: NSDateComponents) -> MonthItemNavigationController? {
        // Instantiate copy of prefab view controller
        let monthItemNavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("MonthItemNavigationController") as! MonthItemNavigationController
        // Load data
        monthItemNavigationController.loadData(calendar!, today: today!, components: components)

        return monthItemNavigationController
    }
}


