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
    
    //private let alarmDateSwitch = UISwitch()
    
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
    @IBOutlet weak var alarmDateSwitch: UISwitch!
    
    // Displays alarm time
    @IBOutlet weak var alarmTimeMainLabel: UILabel!
    @IBOutlet weak var alarmTimeDetailsLabel: UILabel!
    
    // Picks alarm time
    @IBOutlet weak var alarmTimePicker: UIDatePicker!
    
    // Section headers associated with section numbers
    private let sections = ["Name": 0, "Start": 1, "End": 2, "Alarm": 3]
    
    // Keeps track of index paths
    private let indexPaths = ["Name": NSIndexPath(forRow: 0, inSection: 0),
        "Start": NSIndexPath(forRow: 0, inSection: 1), "End": NSIndexPath(forRow: 0, inSection: 2),
        "AlarmToggle": NSIndexPath(forRow: 0, inSection: 3),
        "AlarmDateToggle": NSIndexPath(forRow: 1, inSection: 3),
        "AlarmTimeDisplay": NSIndexPath(forRow: 2, inSection: 3),
        "AlarmTimePicker": NSIndexPath(forRow: 3, inSection: 3)]
    
    // Heights of fields
    private let DEFAULT_CELL_HEIGHT = UITableViewCell().frame.height
    private let PICKER_CELL_HEIGHT = UIPickerView().frame.height
    
    private var eventNameCellHeight: CGFloat
    
    private var eventDateStartCellHeight: CGFloat
    private var eventDateEndCellHeight: CGFloat
    
    private var alarmToggleCellHeight: CGFloat
    private var alarmDateToggleCellHeight: CGFloat
    private var alarmTimeDisplayCellHeight: CGFloat
    private var alarmTimePickerCellHeight: CGFloat
    
    private var selectedIndexPath: NSIndexPath?
    
    // Initialization, set default heights
    required init(coder: NSCoder) {
        eventNameCellHeight = DEFAULT_CELL_HEIGHT
        
        eventDateStartCellHeight = DEFAULT_CELL_HEIGHT
        eventDateEndCellHeight = DEFAULT_CELL_HEIGHT
        
        alarmToggleCellHeight = DEFAULT_CELL_HEIGHT
        alarmDateToggleCellHeight = 0
        alarmTimeDisplayCellHeight = 0
        alarmTimePickerCellHeight = 0
        
        super.init(coder: coder)
    }
    
    
    // Sets initial date for initialization information
    func setInitialDate(date: NSDate) {
        self.date = date
    }
    
    
    // Initialize information on view load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(tableView.frame.size.height)
        
        // Set tableview delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
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
        alarmTimeMainLabel.text = eventDateFormatter.stringFromDate(date!)
        
        // Format and set details labels
        eventDateFormatter.dateFormat = "h:mm a"
        eventDateStartDetailsLabel.text = eventDateFormatter.stringFromDate(date!)
        eventDateEndDetailsLabel.text = eventDateFormatter.stringFromDate(nextHourDate)
        alarmTimeDetailsLabel.text = eventDateFormatter.stringFromDate(date!)
        
        alarmSwitch.on = false
        alarmDateSwitch.on = false

        alarmTimePicker.date = date!
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
            selectedIndexPath = indexPaths["Name"]
            eventNameTextField.userInteractionEnabled = true
            eventNameTextField.becomeFirstResponder()
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        case sections["Start"]!:
            selectedIndexPath = indexPaths["Start"]
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
        case sections["End"]!:
            selectedIndexPath = indexPaths["End"]
            
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
        default:
            break
        }
    }
    
    @IBAction func toggleAlarmOptions(sender: AnyObject) {
        if let alarmToggle = sender as? UISwitch {
            if alarmToggle.on {
                showMoreAlarmOptions()
            }
            else {
                showLessAlarmOptions()
            }
        }
    }
    
    
    // Shows more alarm options
    func showMoreAlarmOptions() {
        println("***MORE***")
        tableView.beginUpdates()
        
        let alarmDateToggleCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmDateToggle"]!)
        let alarmTimeDisplayCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmTimeDisplay"]!)
        let alarmTimePickerCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmTimePicker"]!)
        
        alarmDateToggleCellHeight = DEFAULT_CELL_HEIGHT
        alarmTimeDisplayCellHeight = DEFAULT_CELL_HEIGHT
        alarmTimePickerCellHeight = PICKER_CELL_HEIGHT
        
        alarmDateToggleCell!.hidden = false
        alarmTimeDisplayCell!.hidden = false
        alarmTimePickerCell!.hidden = false
        
        tableView.endUpdates()
    }
    
    
    // Shows less alarm options
    func showLessAlarmOptions() {
        println("***LESS***")
        tableView.beginUpdates()
        
        let alarmDateToggleCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmDateToggle"]!)
        let alarmTimeDisplayCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmTimeDisplay"]!)
        let alarmTimePickerCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmTimePicker"]!)
        
        alarmDateToggleCellHeight = 0
        alarmTimeDisplayCellHeight = 0
        alarmTimePickerCellHeight = 0
        
        alarmDateToggleCell!.hidden = true
        alarmTimeDisplayCell!.hidden = true
        alarmTimePickerCell!.hidden = true
        
        tableView.endUpdates()
    }
    
    
    @IBAction func updateAlarmTimeDisplay(sender: AnyObject) {
        // Main label shows format: month day, year
        eventDateFormatter.dateFormat = "MMM dd, yyyy"
        alarmTimeMainLabel.text = eventDateFormatter.stringFromDate(alarmTimePicker.date)
        
        eventDateFormatter.dateFormat = "h:mm a"
        alarmTimeDetailsLabel.text = eventDateFormatter.stringFromDate(alarmTimePicker.date)
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
            case sections["Start"]!:
                tableView.beginUpdates()
                
                let cell = tableView.cellForRowAtIndexPath(indexPath)!
                eventDateStartPicker.removeFromSuperview()
                eventDateStartCellHeight = DEFAULT_CELL_HEIGHT
                
                eventDateStartMainLabel.hidden = false
                eventDateStartDetailsLabel.hidden = false
                
                tableView.endUpdates()
            // If deselecting date end field, hide date end picker and show labels
            case sections["End"]!:
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
        case sections["Start"]!:
            return eventDateStartCellHeight
        // Event date end field changes height based on if it is selected or not
        case sections["End"]!:
            return eventDateEndCellHeight
        case sections["Alarm"]!:
            switch indexPath.row {
            // Alarm toggle height
            case indexPaths["AlarmToggle"]!.row:
                return alarmToggleCellHeight
            // Use date toggle height
            case indexPaths["AlarmDateToggle"]!.row:
                return alarmDateToggleCellHeight
            // Alarm time display height
            case indexPaths["AlarmTimeDisplay"]!.row:
                return alarmTimeDisplayCellHeight
            // Alarm time picker height
            case indexPaths["AlarmTimePicker"]!.row:
                return alarmTimePickerCellHeight
            default:
                return DEFAULT_CELL_HEIGHT
            }
        default:
            return DEFAULT_CELL_HEIGHT
        }
    }
}
