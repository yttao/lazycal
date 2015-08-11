//: Playground - noun: a place where people can play

import UIKit
import AddressBook

var str = "Hello, playground"
var myDate = NSDate()

var calendar = NSCalendar.currentCalendar()
let hour = calendar.component(NSCalendarUnit.CalendarUnitHour, fromDate: NSDate())
let day = calendar.component(NSCalendarUnit.CalendarUnitDay, fromDate: NSDate())
let month = calendar.component(NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate())

let numDaysInMonth = calendar.rangeOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.CalendarUnitMonth, forDate: NSDate())

var a: Int32 = 7
var b: Int32 = 7
var c: Bool = a == b

var s: String? = nil
var t: String? = "test"
s == t
s = "test"
s == t