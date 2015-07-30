//
//  MonthItemCollectionHeaderView.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/30/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class MonthItemCollectionHeaderView: UICollectionReusableView {
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private var weekdayLabels = [UILabel]()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        for i in 0..<weekdays.count {
            weekdayLabels.append(UILabel())
            weekdayLabels[i].text = weekdays[i]
            weekdayLabels[i].textAlignment = NSTextAlignment.Center
            weekdayLabels[i].sizeToFit()
        }

        addLabels()
    }
    
    func createConstraints() {
        // Allow custom constraints to be added
        weekdayLabels[0].setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let widthConstraint = NSLayoutConstraint(item: weekdayLabels[0], attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.frame.width / 7)
        let heightConstraint = NSLayoutConstraint(item: weekdayLabels[0], attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.frame.size.height)
        let leadingConstraint = NSLayoutConstraint(item: weekdayLabels[0], attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: weekdayLabels[0], attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: weekdayLabels[0], attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0)
        
        weekdayLabels[0].addConstraint(widthConstraint)
        weekdayLabels[0].addConstraint(heightConstraint)
        self.addConstraint(leadingConstraint)
        self.addConstraint(centerYConstraint)
    }
    
    // Adds labels as subviews
    private func addLabels() {
        
        //for label in weekdayLabels {
        //    self.addSubview(label)
        //}
        self.addSubview(weekdayLabels[0])
    }
}