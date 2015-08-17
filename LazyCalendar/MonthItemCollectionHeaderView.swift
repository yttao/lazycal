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
    
    private let borderColor = UIColor(red: 0.1, green: 0.5, blue: 0.9, alpha: 0.8)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Add label text and resize label to fit text
        for i in 0..<weekdays.count {
            weekdayLabels.append(UILabel())
            weekdayLabels[i].text = weekdays[i]
            weekdayLabels[i].textAlignment = NSTextAlignment.Center
            weekdayLabels[i].sizeToFit()
        }

        addLabels()
    }
    
    /**
        Sets up the label constraints.
    */
    func addConstraints() {
        // Add width, height, and center Y constraints
        for weekdayLabel in weekdayLabels {
            // Allows custom constraints to be added
            weekdayLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            let widthConstraint = NSLayoutConstraint(item: weekdayLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: frame.width / 7)
            let heightConstraint = NSLayoutConstraint(item: weekdayLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: frame.size.height)
            let centerYConstraint = NSLayoutConstraint(item: weekdayLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0)
            
            weekdayLabel.addConstraints([widthConstraint, heightConstraint])
            addConstraint(centerYConstraint)
        }
        
        // Set first constraint to match first label leading edge and superview leading edge.
        let firstLeadingConstraint = NSLayoutConstraint(item: weekdayLabels[0], attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0)
        addConstraint(firstLeadingConstraint)
        // Set the other constraints to line up with the trailing edge of label to the left.
        for i in 1..<weekdayLabels.count {
            let leadingConstraint = NSLayoutConstraint(item: weekdayLabels[i], attribute: .Leading, relatedBy: .Equal, toItem: weekdayLabels[i - 1], attribute: .Trailing, multiplier: 1.0, constant: 0)
            addConstraint(leadingConstraint)
        }
    }
    
    /**
        Adds borders to labels.
    */
    func addBorders() {
        for i in 1..<weekdayLabels.count {
            let weekdayLabel = weekdayLabels[i]
            weekdayLabel.clipsToBounds = true
            let leftBorderLayer = CALayer(layer: weekdayLabel.layer)
            leftBorderLayer.borderColor = borderColor.CGColor
            leftBorderLayer.borderWidth = 1
            leftBorderLayer.frame = CGRectMake(0, 0, 1, weekdayLabel.bounds.height + 30)
            weekdayLabel.layer.addSublayer(leftBorderLayer)
        }
    }
    
    /**
        Adds labels as subviews.
    */
    private func addLabels() {
        for label in weekdayLabels {
            addSubview(label)
            didAddSubview(label)
        }
    }
}