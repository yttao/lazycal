//
//  ChangeEventViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/9/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class ChangeEventViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    // Calendar
    private let calendar = NSCalendar.currentCalendar()
    
    // Date used for initialization info
    private var date: NSDate?
    
    // Date formatter to control date appearances
    private let eventDateFormatter = NSDateFormatter()
    
    // Date start and end pickers to decide time interval
    private let eventDateStartPicker = UIDatePicker()
    private let eventDateEndPicker = UIDatePicker()
    
    // Text field for event name
    @IBOutlet weak var eventNameTextField: UITextField!
    
    // Labels to display event start info
    @IBOutlet weak var eventDateStartMainLabel: UILabel!
    @IBOutlet weak var eventDateStartDetailsLabel: UILabel!
    
    // Labels to display event end info
    @IBOutlet weak var eventDateEndMainLabel: UILabel!
    @IBOutlet weak var eventDateEndDetailsLabel: UILabel!
    
    // Toggles alarm option on/off
    @IBOutlet weak var alarmSwitch: UISwitch!
    
    // Section headers associated with section numbers
    private let sections = ["Name": 0, "From": 1, "To": 2, "Alarm": 3]
    
    // Heights of fields\
    private let DEFAULT_CELL_HEIGHT = UITableViewCell().frame.height
    private var eventNameCellHeight: CGFloat
    private var eventDateStartCellHeight: CGFloat
    private var eventDateEndCellHeight: CGFloat
    
    
    // Initialization, set default heights
    required init(coder: NSCoder) {
        eventNameCellHeight = DEFAULT_CELL_HEIGHT
        eventDateStartCellHeight = DEFAULT_CELL_HEIGHT
        eventDateEndCellHeight = DEFAULT_CELL_HEIGHT
        
        super.init(coder: coder)
    }
    
    
    // Sets initial date for initialization information
    func setInitialDate(date: NSDate) {
        self.date = date
    }
    
    
    // Initialize information on view load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set tableview delegate and data source
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Disable text field user interaction, needed to allow proper table view row selection
        eventNameTextField.userInteractionEnabled = false
        
        // Set initial picker value to selected date and end picker value to 1 hour later
        eventDateStartPicker.date = date!
        let hour = NSTimeInterval(3600)
        let nextHourDate = date!.dateByAddingTimeInterval(hour)
        eventDateEndPicker.date = nextHourDate
        
        // Add listener for when date start and end pickers update
        eventDateStartPicker.addTarget(self, action: "updateEventDateStartLabels", forControlEvents:
            .ValueChanged)
        eventDateEndPicker.addTarget(self, action: "updateEventDateEndLabels", forControlEvents: .ValueChanged)
        
        // Format and set main date labels
        eventDateFormatter.dateFormat = "MMM dd, yyyy"
        eventDateStartMainLabel.text = eventDateFormatter.stringFromDate(date!)
        eventDateEndMainLabel.text = eventDateFormatter.stringFromDate(nextHourDate)
        
        // Format and set details labels
        eventDateFormatter.dateFormat = "h:mm a"
        eventDateStartDetailsLabel.text = eventDateFormatter.stringFromDate(date!)
        eventDateEndDetailsLabel.text = eventDateFormatter.stringFromDate(nextHourDate)
    }


    // When date start picker changes, update date start labels
    func updateEventDateStartLabels() {
        eventDateFormatter.dateFormat = "MMM dd, yyyy"
        eventDateStartMainLabel.text = eventDateFormatter.stringFromDate(eventDateStartPicker.date)
        
        eventDateFormatter.dateFormat = "h:mm a"
        eventDateStartDetailsLabel.text = eventDateFormatter.stringFromDate(eventDateStartPicker.date)
    }
    
    
    // When date end picker changes, update date end labels
    func updateEventDateEndLabels() {
        eventDateFormatter.dateFormat = "MMM dd, yyyy"
        eventDateEndMainLabel.text = eventDateFormatter.stringFromDate(eventDateEndPicker.date)
        
        eventDateFormatter.dateFormat = "h:mm a"
        eventDateEndDetailsLabel.text = eventDateFormatter.stringFromDate(eventDateEndPicker.date)
    }
    
    
    // Number of fields to fill in
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("***Selected: \(indexPath.section)\t\(indexPath.row)")
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        // Take action based on what section was chosen
        switch indexPath.section {
        case sections["Name"]!:
            tableView.reloadData()
            eventNameTextField.userInteractionEnabled = true
            eventNameTextField.becomeFirstResponder()
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        case sections["From"]!:
            // Hide date start labels
            eventDateStartMainLabel.hidden = true
            eventDateStartDetailsLabel.hidden = true
            
            // Show date start picker
            tableView.beginUpdates()
            
            // Recalculate height to show date start picker
            eventDateStartCellHeight = eventDateStartPicker.frame.height
            
            cell.contentView.addSubview(eventDateStartPicker)
            cell.contentView.didAddSubview(eventDateStartPicker)
            
            tableView.endUpdates()
        case sections["To"]!:
            // Hide date end labels
            eventDateEndMainLabel.hidden = true
            eventDateEndDetailsLabel.hidden = true
            
            // Show date end picker
            tableView.beginUpdates()
            
            // Recalculate height to show date end picker
            eventDateEndCellHeight = eventDateEndPicker.frame.height
            
            cell.contentView.addSubview(eventDateEndPicker)
            cell.contentView.didAddSubview(eventDateEndPicker)
            
            tableView.endUpdates()
        case sections["Alarm"]!:
            println("Alarm")
        default:
            break
        }
    }
    
    
    // Called on cell deselection (when a different cell is selected)
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        println("***Deselected: \(indexPath.section)\t\(indexPath.row)***")
        switch indexPath.section {
            // If deselecting event name field, text field stops being first responder and disables
            // user interaction with it.
            case sections["Name"]!:
                eventNameTextField.userInteractionEnabled = false
                eventNameTextField.resignFirstResponder()
            // If deselecting date start field, hide date start picker and show labels
            case sections["From"]!:
                tableView.beginUpdates()
                
                let cell = tableView.cellForRowAtIndexPath(indexPath)!
                eventDateStartPicker.removeFromSuperview()
                eventDateStartCellHeight = DEFAULT_CELL_HEIGHT
                
                eventDateStartMainLabel.hidden = false
                eventDateStartDetailsLabel.hidden = false
                
                tableView.endUpdates()
            // If deselecting date end field, hide date end picker and show labels
            case sections["To"]!:
                tableView.beginUpdates()
                
                let cell = tableView.cellForRowAtIndexPath(indexPath)!
                eventDateEndPicker.removeFromSuperview()
                eventDateEndCellHeight = DEFAULT_CELL_HEIGHT
                
                eventDateEndMainLabel.hidden = false
                eventDateEndDetailsLabel.hidden = false
                
                tableView.endUpdates()
            default:
                break
        }
    }
    
    
    // Calculates height for rows
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
            // Event name field has default height
            case sections["Name"]!:
                return eventNameCellHeight
            // Event date start field changes height based on if it is selected or not
            case sections["From"]!:
                return eventDateStartCellHeight
            // Event date end field changes height based on if it is selected or not
            case sections["To"]!:
                return eventDateEndCellHeight
            default:
                return DEFAULT_CELL_HEIGHT
        }
    }
}
