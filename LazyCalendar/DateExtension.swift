//
//  DateExtension.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/13/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import Foundation

extension NSDate {
    /**
        Compares two units between two dates.
    */
    func compareUnits(#otherDate: NSDate, units: NSCalendarUnit) -> NSComparisonResult? {
        let calendar = NSCalendar.currentCalendar()
        let firstDateComponents = calendar.components(units, fromDate: self)
        let secondDateComponents = calendar.components(units, fromDate: otherDate)
        
        let firstDate = calendar.dateFromComponents(firstDateComponents)
        let secondDate = calendar.dateFromComponents(secondDateComponents)
        if let firstDate = firstDate, secondDate = secondDate {
            return firstDate.compare(secondDate)
        }
        return nil
    }
}