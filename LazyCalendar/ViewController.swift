//
//  ViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 6/29/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var pageViewController: UIPageViewController?
    
    // 7 days in a week
    private let numDaysInWeek = 7
    // 5 weeks (overlapping with weeks in adjacent months) in a month
    private let numWeeksInMonth = 5
    // Max number of cells
    private let numCellsInMonth = 35
    
    private var calendar: NSCalendar?
    private var today: NSDate?
    // Keeps track of current date view
    private var dateComponents: NSDateComponents?
    // NSCalendarUnits to keep track of
    private let units = NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth |
        NSCalendarUnit.CalendarUnitYear
    private var currentIndex = 0
    private var nextIndex = 0
    
    var selectedDate: NSDate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        calendar = NSCalendar.currentCalendar()
        today = NSDate()
        dateComponents = calendar!.components(units, fromDate: today!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPageViewController()
        print("View loaded fully")
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
    
    // Gets the first weekday of the month
    func getMonthStartWeekday(components: NSDateComponents) -> Int {
        var componentsCopy = components.copy() as! NSDateComponents
        componentsCopy.day = 1
        var startMonthDate = calendar!.dateFromComponents(componentsCopy)
        var startMonthDateComponents = calendar!.components(.CalendarUnitWeekday, fromDate: startMonthDate!)
        return startMonthDateComponents.weekday
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
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("MonthController") as! UIPageViewController
        // Set data source and delegate
        pageController.dataSource = self
        pageController.delegate = self
        // Make first view controller
        let firstController = getMonthController(dateComponents!)!
        let startingViewController = [firstController]
        // Set initial view controller
        pageController.setViewControllers(startingViewController, direction: UIPageViewControllerNavigationDirection.Forward , animated: false, completion: nil)
        println("Page controllers set: \(pageController.viewControllers)")
        
        pageViewController = pageController
        self.addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        /*pageViewController!.didMoveToParentViewController(self)*/
    }
    
    // Function to handle direction change - call goToNextMonth/goToPrevMonth twice instead of once

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        println("BEFORE")
        let components = dateComponents!.copy() as! NSDateComponents
        components.month--
        let newComponents = getNewDateComponents(components)
        let monthStartWeekday = getMonthStartWeekday(newComponents)
        /*println("Month: \(newComponents.month), Weekday: \(monthStartWeekday)")*/

        
        return getMonthController(newComponents)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        println("AFTER")
        let components = dateComponents!.copy() as! NSDateComponents
        components.month++
        let newComponents = getNewDateComponents(components)
        let monthStartWeekday = getMonthStartWeekday(dateComponents!)
        /*println("Month: \(newComponents.month), Weekday: \(monthStartWeekday)")*/
        
        return getMonthController(newComponents)
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
        let currentViewController = pageViewController.viewControllers[0] as! CalendarCollectionViewController
        let nextViewController = pendingViewControllers[0] as! CalendarCollectionViewController
        
        println("CURRENT: \(currentViewController.dateIndex)")
        println("NEXT: \(nextViewController.dateIndex)")
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        println("Did finish animating")
        let newViewController = pageViewController.viewControllers[0] as! CalendarCollectionViewController
        let oldViewController = previousViewControllers[0] as! CalendarCollectionViewController
        
        if (oldViewController.dateIndex!.compare(newViewController.dateIndex!) ==
            NSComparisonResult.OrderedAscending) {
                goToNextMonth()
        }
        else if (oldViewController.dateIndex!.compare(newViewController.dateIndex!) ==
            NSComparisonResult.OrderedDescending) {
                goToPrevMonth()
        }
    }
    
    // Creates month view controller
    private func getMonthController(components: NSDateComponents) -> CalendarCollectionViewController? {
        // Instantiate copy of prefab view controller
        let calendarCollectionViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MonthItemController") as! CalendarCollectionViewController
        calendarCollectionViewController.loadData(calendar!, today: today!, dateComponents: components)

        return calendarCollectionViewController
    }
}

