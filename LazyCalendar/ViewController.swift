//
//  ViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 6/29/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPageViewControllerDataSource {
    var pageViewController: UIPageViewController?
    
    private var calendar: NSCalendar?
    
    // 7 days in a week
    private let numDaysInWeek = 7
    // 5 weeks (overlapping with weeks in adjacent months) in a month
    private let numWeeksInMonth = 5
    // Max number of cells
    private let numCellsInMonth = 35
    
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
        println("Swipe left")
        dateComponents!.month++
        dateComponents!.day = 1
        dateComponents = getNewDateComponents(dateComponents!)
    }
    
    func goToPrevMonth() {
        println("Swipe right")
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
        // Set data source to self
        pageController.dataSource = self
        // Make first view controller
        let firstController = getMonthController(dateComponents!)!
        let startingViewControllers = [firstController]
        pageController.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        pageViewController = pageController
        self.addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        println("PREV MONTH FOR \(viewController.description)")
        goToPrevMonth()
        let monthStartWeekday = getMonthStartWeekday(dateComponents!)
        println("Current month: \(dateComponents!.month), Weekday: \(monthStartWeekday)")
        println(dateComponents!.description)
        let components = dateComponents!.copy() as! NSDateComponents
        components.month--
        
        return getMonthController(getNewDateComponents(components))
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        println("NEXT MONTH for \(viewController.description)")
        goToNextMonth()
        let monthStartWeekday = getMonthStartWeekday(dateComponents!)
        println("Current month: \(dateComponents!.month), Weekday: \(monthStartWeekday)")
        println(dateComponents!.description)
        let components = dateComponents!.copy() as! NSDateComponents
        components.month++
        
        return getMonthController(getNewDateComponents(components))
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
    }
    
    // Creates month view controller
    private func getMonthController(components: NSDateComponents) -> CalendarCollectionViewController? {
        // Instantiate copy of prefab view controller
        let calendarCollectionViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MonthItemController") as! CalendarCollectionViewController
        calendarCollectionViewController.loadData(calendar!, today: today!, dateComponents: components)
        // TODO: Figure out how to load date info into collectionviewcontroller before creating it.
        return calendarCollectionViewController
    }
}

