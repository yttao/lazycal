//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
var myDate = NSDate()
print(myDate)

var calendar = NSCalendar.currentCalendar()
let hour = calendar.component(NSCalendarUnit.CalendarUnitHour, fromDate: NSDate())
let day = calendar.component(NSCalendarUnit.CalendarUnitDay, fromDate: NSDate())
let month = calendar.component(NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate())

let numDaysInMonth = calendar.rangeOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.CalendarUnitMonth, forDate: NSDate())
let numDaysInYear = calendar.rangeOfUnit(NSCalendarUnit.CalendarUnitMonth, inUnit: NSCalendarUnit.CalendarUnitYear, forDate: NSDate())


var today = NSDate()

var daysSinceMonthStart = calendar.rangeOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.CalendarUnitMonth, forDate: NSDate())

var sevenDaysAgo = today.dateByAddingTimeInterval(-7 * 24 * 60 * 60)

var weekdayComponents = calendar.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: NSDate())
var components = calendar.components(NSCalendarUnit.CalendarUnitMonth |
    NSCalendarUnit.CalendarUnitWeekday, fromDate: today)
components.day = 1
components.description
components.weekday
