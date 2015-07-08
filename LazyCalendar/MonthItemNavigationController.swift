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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func loadData(components: NSDateComponents) {
        dateComponents = components
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
