//
//  AlarmPickerView.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/14/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class AlarmPickerView: UIPickerView, UIPickerViewDataSource {
    private let fields: Dictionary<String, Dictionary<String, Int>> = ["Days": ["component": 0, "maxValue": 30], "Hours": ["component": 1, "maxValue": 23], "Minutes": ["component": 2, "maxValue": 59]]
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return fields.count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case fields["Days"]!["component"]!:
            return fields["Days"]!["maxValue"]!
        case fields["Hours"]!["component"]!:
            return fields["Hours"]!["maxValue"]!
        case fields["Minutes"]!["component"]!:
            return fields["Minutes"]!["maxValue"]!
        default:
            assert(false, "Invalid field")
        }
    }
}
