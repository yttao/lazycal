//
//  ViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 9/2/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var picker1: UIDatePicker!
    @IBOutlet weak var picker2: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        picker1.timeZone = NSTimeZone.localTimeZone()
        picker1.timeZone = NSTimeZone(abbreviation: "EDT")
        picker2.timeZone = NSTimeZone.localTimeZone()
        picker2.timeZone = NSTimeZone(abbreviation: "CDT")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func picker1change(sender: AnyObject) {
        refreshDatePickerTimeZone(picker1)
    }
    
    @IBAction func picker2change(sender: AnyObject) {
        refreshDatePickerTimeZone(picker2)
    }
    
    /**
    */
    func refreshDatePickerTimeZone(datePicker: UIDatePicker) {
        // Get date picker time zone.
        let timeZone = datePicker.timeZone
        
        // Reset time zone
        if datePicker.timeZone != NSTimeZone(abbreviation: "EDT") {
            datePicker.timeZone = NSTimeZone(abbreviation: "EDT")
        }
        else {
            datePicker.timeZone = NSTimeZone(abbreviation: "PDT")
        }
        // Set time zone to correct time zone.
        datePicker.timeZone = timeZone
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
