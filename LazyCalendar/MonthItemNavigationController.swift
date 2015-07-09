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
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        monthItemViewController = self.viewControllers.first as? MonthItemViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func loadData(calendar: NSCalendar, today: NSDate, components: NSDateComponents) {
        dateComponents = components
        monthItemViewController!.loadData(calendar, today: today, dateComponents: components)
    }
}
