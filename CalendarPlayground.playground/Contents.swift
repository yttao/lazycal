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

var a: [NSDate]?
let test1: Bool = a?.count > 0
if a?.count > 0 {
    println("Hi")
}
a = [NSDate]()
let test2: Bool = a?.count > 0
let test3: Bool = nil < -INT64_MAX
let test4: Bool = nil != 0

let units: NSCalendarUnit = .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute

let firstCalendar = NSCalendar.currentCalendar()

let secondCalendar = NSCalendar.currentCalendar()
secondCalendar.timeZone = NSTimeZone(name: "America/Chicago")!

let date = NSDate()
let firstComponents = firstCalendar.components(units, fromDate: date)
let secondComponents = secondCalendar.components(.CalendarUnitHour, fromDate: date)
let thirdComponents = firstCalendar.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: date)
let newDate1 = firstCalendar.dateFromComponents(firstComponents)!
let newDate2 = secondCalendar.dateFromComponents(firstComponents)!

let dateComponents = firstCalendar.components(units, fromDate: date)
let newDate3 = secondCalendar.dateFromComponents(firstComponents)





















