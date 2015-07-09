//
//  MonthItemNavigationController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/8/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class MonthItemNavigationController: UINavigationController {
    private var dateComponents: NSDateComponents?
    private var monthItemViewController: MonthItemViewController?
    
    // Initialize with embedded month item view controller
    required init(coder: NSCoder) {
        super.init(coder: coder)
        monthItemViewController = self.viewControllers.first as? MonthItemViewController
    }
    
    // Loads data into month item view controller
    func loadData(calendar: NSCalendar, components: NSDateComponents) {
        dateComponents = components
        monthItemViewController!.loadData(calendar, dateComponents: components)
    }
}
