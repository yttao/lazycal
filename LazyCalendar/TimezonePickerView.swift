//
//  TimezonePickerView.swift
//  LazyCalendar
//
//  Created by Ying Tao on 9/1/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class TimezonePickerView: UIPickerView {
    // TODO: Make a picker with all the options of known time zones.
    static let timezones = NSTimeZone.knownTimeZoneNames() as! [String]
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        for timezone in TimezonePickerView.timezones {
            println(timezone)
            let zone = NSTimeZone(name: timezone)
            println(zone?.abbreviation)
        }
        
        dataSource = self
        delegate = self
    }
}

extension TimezonePickerView: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TimezonePickerView.timezones.count
    }
}

extension TimezonePickerView: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return TimezonePickerView.timezones[row]
    }
}