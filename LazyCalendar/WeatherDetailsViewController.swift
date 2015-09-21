//
//  WeatherDetailsViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 9/5/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class WeatherDetailsViewController: UIViewController {
    var event: LZEvent!
    // The location to display weather for
    var location: LZLocation!
    
    let calendar = NSCalendar.currentCalendar()
    
    @IBOutlet weak var dailyScrollView: UIScrollView!
    @IBOutlet weak var hourlyScrollView: UIScrollView!
    @IBOutlet weak var detailsScrollView: UIScrollView!
    
    let marginConstant: CGFloat = 8.0
    let detailsScrollViewHeight: CGFloat = 204.0
    
    var dailyItems = [WeatherDetailsItemView]()
    var hourlyItems = [WeatherDetailsItemView]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Determine if the event spans multiple days. If so, display the daily scroll view. If not, remove it.
        let dateStartComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: event.dateStart)
        let dateEndComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: event.dateEnd)
        let dateStart = calendar.dateFromComponents(dateStartComponents)
        let dateEnd = calendar.dateFromComponents(dateEndComponents)
        
        // If date start and date end aren't the same days (in the user's calendar timezone), remove the daily scroll view.
        if dateStart != dateEnd {
            addConstraints(dailyScrollView: false)
        }
        else {
            addConstraints(dailyScrollView: true)
        }
    }
    
    /**
        Loads initial data into the view controller.
        
        :param: event The event to show weather for.
        :param: location The location to show weather for.
    */
    func loadData(event: LZEvent, location: LZLocation) {
        self.event = event
        self.location = location
    }
    
    func addConstraints(#dailyScrollView: Bool) {
        self.dailyScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        hourlyScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        detailsScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        hourlyScrollView.hidden = true
        detailsScrollView.hidden = true
        
        /*if dailyScrollView {
            let dailyScrollViewTopConstraint = NSLayoutConstraint(item: self.dailyScrollView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: marginConstant)
            let dailyScrollViewLeadingConstraint = NSLayoutConstraint(item: self.dailyScrollView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: marginConstant)
            let dailyScrollViewTrailingConstraint = NSLayoutConstraint(item: self.dailyScrollView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: marginConstant)
            let dailyScrollViewHeightConstraint = NSLayoutConstraint(item: self.dailyScrollView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: (view.frame.height - 2 * marginConstant) * 1 / 3)
            view.addConstraints([dailyScrollViewTopConstraint, dailyScrollViewLeadingConstraint, dailyScrollViewTrailingConstraint])
            self.dailyScrollView.addConstraint(dailyScrollViewHeightConstraint)
        }
        else {
            self.dailyScrollView.removeFromSuperview()
            
            
        }*/
    }
}