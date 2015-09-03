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
    
        If for some reason either of the dates are invalid (ex: nonexistent dates), the function will return nil.
    
        TODO: Account for different timezones when implemented.
    */
    func compareUnits(otherDate: NSDate, units: NSCalendarUnit) -> NSComparisonResult? {
        // Compare dates in the same time zone.
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
    
    /**
        Returns a date in the given time zone.
    
        :param: timeZone The time zone to convert to.
        :returns: The date in the given time zone.
    */
    func forTimeZone(timeZone: NSTimeZone) -> NSDate {
        // Units relevant
        let units: NSCalendarUnit = .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute
        
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = timeZone
        
        let dateComponents = calendar.components(units, fromDate: self)
        let newDate = calendar.dateFromComponents(dateComponents)!
        return newDate
    }
}

extension NSDateFormatter {
    /**
        Creates a string for a date interval.
    
        TODO: Add timezone if it is not the same as the currentCalendar timezone.
    */
    func stringFromDateInterval(fromDate date: NSDate, toDate otherDate: NSDate, fromTimeZone timeZone: NSTimeZone = NSTimeZone.localTimeZone(), toTimeZone otherTimeZone: NSTimeZone = NSTimeZone.localTimeZone()) -> String {
        var dateInterval = ""
        if date.compareUnits(otherDate, units: .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear) == .OrderedSame {
            dateFormat = "MMM dd, yyyy"
            dateInterval = "\(stringFromDate(date)) "
            if date.compareUnits(otherDate, units: .CalendarUnitHour | .CalendarUnitMinute) == .OrderedSame {
                // If the event date start and end times are the same, return the date and time in this format:
                // MMM dd, yyyy h:mm a
                dateFormat = "h:mm a"
                dateInterval += "\(stringFromDate(date))"
                
                // TODO: figure out where this goes, maybe higher up.
                if timeZone != NSTimeZone.localTimeZone() {
                    dateFormat = "zzz"
                    self.timeZone = timeZone
                    dateInterval += " \(stringFromDate(date))"
                }
            }
            else {
                // If the event date start and end times are different, show the date and time in this format:
                // MMM dd, yyyy h:mm a - h:mm a
                dateFormat = "h:mm a"
                dateInterval += "\(stringFromDate(date)) "
                if timeZone != NSTimeZone.localTimeZone() {
                    dateInterval += "\(timeZone.abbreviation!) "
                }
                dateInterval += "- \(stringFromDate(otherDate))"
                if otherTimeZone != NSTimeZone.localTimeZone() {
                    dateInterval += "\( otherTimeZone.abbreviation!)"
                }
            }
        }
        else {
            // If the event date start and end dates are different, return the date and time in this format:
            // MMM dd, yyyy h:mm a - MMM dd, yyyy h:mm a
            dateFormat = "MMM dd, yyyy h:mm a"
            dateInterval = "\(stringFromDate(date)) "
            if timeZone != NSTimeZone.localTimeZone() {
                dateInterval += "\(timeZone.abbreviation!) "
            }
            dateInterval += "- \(stringFromDate(otherDate))"
            if otherTimeZone != NSTimeZone.localTimeZone() {
                dateInterval += " \( otherTimeZone.abbreviation!)"
            }
        }
        
        return dateInterval
    }
}

extension NSTimeZone {
    /**
        Returns the time zone name in a readable string form.
    
        :returns: The time zone name as a readable string.
    */
    func nameString() -> String {
        // Remove underscores
        let timeZoneNameNoUnderscores = name.stringByReplacingOccurrencesOfString("_", withString: " ")
        
        // Delimit string by "/"
        let timeZoneNameArray = timeZoneNameNoUnderscores.componentsSeparatedByString("/")
        // Reverse order of time zone name components (so it goes from most specific location name to most general location name)
        let reversedTimeZoneNameArray = timeZoneNameArray.reverse()
        
        // Separate components of the time zone name by commas.
        return ", ".join(reversedTimeZoneNameArray)
    }
}