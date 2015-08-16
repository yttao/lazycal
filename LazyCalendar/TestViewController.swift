//
//  TestViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/15/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    var testSegmentedControl = MultipleSelectionSegmentedControl(items: ["First", "Second", "Third"])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        testSegmentedControl.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        view.addSubview(testSegmentedControl)
        view.didAddSubview(testSegmentedControl)
        
        let trailingConstraint = NSLayoutConstraint(item: testSegmentedControl, attribute: .Trailing, relatedBy: .Equal, toItem: testSegmentedControl.superview, attribute: .Trailing, multiplier: 1, constant: -8)
        let bottomConstraint = NSLayoutConstraint(item: testSegmentedControl, attribute: .Bottom, relatedBy: .Equal, toItem: testSegmentedControl.superview, attribute: .Bottom, multiplier: 1, constant: -8)
        view.addConstraint(trailingConstraint)
        view.addConstraint(bottomConstraint)
    }
}
