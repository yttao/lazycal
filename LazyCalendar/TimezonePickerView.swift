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
        
        dataSource = self
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