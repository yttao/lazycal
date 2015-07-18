//
//  ChangeEventViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/9/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import CoreData

class ChangeEventViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: ChangeEventViewControllerDelegate?
    
    // Calendar
    private let calendar = NSCalendar.currentCalendar()
    
    // Date used for initialization info
    var date: NSDate?
    
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
    required init(coder aDecoder: NSCoder) {
        eventNameCellHeight = DEFAULT_CELL_HEIGHT
        
        eventDateStartCellHeight = DEFAULT_CELL_HEIGHT
        eventDateEndCellHeight = DEFAULT_CELL_HEIGHT
        
        alarmToggleCellHeight = DEFAULT_CELL_HEIGHT
        alarmDateToggleCellHeight = 0
        alarmTimeDisplayCellHeight = 0
        alarmTimePickerCellHeight = 0
        
        super.init(coder: aDecoder)
    }
    
    
    // Sets initial date for initialization information
    func setInitialDate(date: NSDate) {
        self.date = date
    }
    
    
    /*
        @brief Initialize information on view load.
        @discussion Provides setup information for the initial data, before the user changes anything.
        1. Set the table view delegate and data source if they are not already set.
        2. Disable the event name text field. This is done to allow proper cell selection (which is not possible if the text field can be clicked on within its section).
        3. Set date start picker date to the selected date (or the first day of the month if none are selected) and the picker time to the current time (in hours and minutes). Set date end picker time to show one hour after the date start picker date and time.
        4. Add event listeners that are informed when event date start picker or end picker are changed. Update the event start and end labels. Additionally, if the event start time is changed, the minimum time for the event end time is modified if the end time will come before the start time.
        5. Format the event start and end labels. The main labels show the format: month day, year. The details labels show the format: hour:minutes period.
        6. Default set the alarm switches off and the alarm time picker to the initial date start.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set tableview delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Disable text field user interaction, needed to allow proper table view row selection
        eventNameTextField.userInteractionEnabled = false
        
        // Set initial picker value to selected date and end picker value to 1 hour later
        eventDateStartPicker.date = date!
        let hour = NSTimeInterval(60 * 60)
        let nextHourDate = date!.dateByAddingTimeInterval(hour)
        eventDateEndPicker.date = nextHourDate
        
        // Add listener for when date start and end pickers update
        eventDateStartPicker.addTarget(self, action: "updateEventDateStartLabels", forControlEvents:
            .ValueChanged)
        eventDateEndPicker.addTarget(self, action: "updateEventDateEndLabels", forControlEvents: .ValueChanged)
        eventDateStartPicker.addTarget(self, action: "updateEventDateEndPicker", forControlEvents: .ValueChanged)
        
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

    
    /*
        @brief When date start picker changes, update date start labels.
    */
    func updateEventDateStartLabels() {
        eventDateFormatter.dateFormat = "MMM dd, yyyy"
        eventDateStartMainLabel.text = eventDateFormatter.stringFromDate(eventDateStartPicker.date)
        
        eventDateFormatter.dateFormat = "h:mm a"
        eventDateStartDetailsLabel.text = eventDateFormatter.stringFromDate(eventDateStartPicker.date)
        println(eventDateStartPicker.date)
    }
    
    
    /*
        @brief When date end picker changes, update date end labels
    */
    func updateEventDateEndLabels() {
        eventDateFormatter.dateFormat = "MMM dd, yyyy"
        eventDateEndMainLabel.text = eventDateFormatter.stringFromDate(eventDateEndPicker.date)
        
        eventDateFormatter.dateFormat = "h:mm a"
        eventDateEndDetailsLabel.text = eventDateFormatter.stringFromDate(eventDateEndPicker.date)
    }
    
    
    /*
        @brief When date start picker is changed, update the minimum date.
        @discussion The date end picker should not be able to choose a date before the date start, so it 
        should have a lower limit placed on the date it can choose.
    */
    func updateEventDateEndPicker() {
        let originalDate = eventDateEndPicker.date
        eventDateEndPicker.minimumDate = eventDateStartPicker.date

        // If the old date end comes after the new date start, change the old date end to equal the new date start.
        if (originalDate.compare(eventDateStartPicker.date) == .OrderedAscending) {
            eventDateEndPicker.date = eventDateStartPicker.date
            updateEventDateEndLabels()
        }
        eventDateEndPicker.reloadInputViews()
    }
    
    
    /*
        @brief Number of sections in table view.
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    

    /*
        @brief Performs actions based on selected index path.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("***Selected: \(indexPath.section)\t\(indexPath.row)")
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        selectedIndexPath = indexPath
        // Take action based on what section was chosen
        switch indexPath.section {
        case sections["Name"]!:
            eventNameTextField.userInteractionEnabled = true
            eventNameTextField.becomeFirstResponder()
        case sections["Start"]!:
            tableView.beginUpdates()
            
            // Hide date start labels
            eventDateStartMainLabel.hidden = true
            eventDateStartDetailsLabel.hidden = true
            
            // Recalculate height to show date start picker
            eventDateStartCellHeight = eventDateStartPicker.frame.height
            
            // Show date start picker
            cell.contentView.addSubview(eventDateStartPicker)
            cell.contentView.didAddSubview(eventDateStartPicker)
            
            tableView.endUpdates()
        case sections["End"]!:
            tableView.beginUpdates()
            
            // Hide date end labels
            eventDateEndMainLabel.hidden = true
            eventDateEndDetailsLabel.hidden = true
            
            // Recalculate height to show date end picker
            eventDateEndCellHeight = eventDateEndPicker.frame.height
            
            // Show date end picker
            cell.contentView.addSubview(eventDateEndPicker)
            cell.contentView.didAddSubview(eventDateEndPicker)
            
            tableView.endUpdates()
        default:
            break
        }
    }
    
    
    /*
        @brief On alarm switch toggle, show more or less options.
    */
    @IBAction func toggleAlarmOptions(sender: AnyObject) {
        if let alarmToggle = sender as? UISwitch {
            // On alarm switch press, deselect current selection
            if selectedIndexPath != nil && selectedIndexPath != indexPaths["AlarmToggle"] {
                deselectRowAtIndexPath(selectedIndexPath!)
            }
            selectedIndexPath = indexPaths["AlarmToggle"]
            if alarmToggle.on {
                showMoreAlarmOptions()
            }
            else {
                showFewerAlarmOptions()
            }
        }
    }
    
    
    /*
        @brief Shows more alarm options
    */
    func showMoreAlarmOptions() {
        println("***MORE***")
        tableView.beginUpdates()
        
        // Get alarm options cells
        let alarmDateToggleCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmDateToggle"]!)
        let alarmTimeDisplayCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmTimeDisplay"]!)
        let alarmTimePickerCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmTimePicker"]!)
        
        // Set cell heights
        alarmDateToggleCellHeight = DEFAULT_CELL_HEIGHT
        alarmTimeDisplayCellHeight = DEFAULT_CELL_HEIGHT
        alarmTimePickerCellHeight = PICKER_CELL_HEIGHT
        
        // Show options
        alarmDateToggleCell!.hidden = false
        alarmTimeDisplayCell!.hidden = false
        alarmTimePickerCell!.hidden = false
        
        tableView.endUpdates()
    }
    
    
    /*
        @brief Shows fewer alarm options
    */
    func showFewerAlarmOptions() {
        println("***LESS***")
        tableView.beginUpdates()
        
        // Get alarm options cells
        let alarmDateToggleCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmDateToggle"]!)
        let alarmTimeDisplayCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmTimeDisplay"]!)
        let alarmTimePickerCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmTimePicker"]!)
        
        // Set cell heights to 0
        alarmDateToggleCellHeight = 0
        alarmTimeDisplayCellHeight = 0
        alarmTimePickerCellHeight = 0
        
        // Hide options
        alarmDateToggleCell!.hidden = true
        alarmTimeDisplayCell!.hidden = true
        alarmTimePickerCell!.hidden = true
        
        tableView.endUpdates()
    }
    
    
    /*
        @brief Update alarm time display when alarm time picker is changed.
    */
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
        deselectRowAtIndexPath(indexPath)
    }
    
    
    /*
        @brief Performs deselection of the field.
    */
    func deselectRowAtIndexPath(indexPath: NSIndexPath) {
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
        selectedIndexPath = nil
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
    
    
    /*
        @brief Saves an event's data.
    */
    func saveEvent() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("TestEvent", inManagedObjectContext: managedContext)!
        
        // Create event
        let event = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedContext)
        
        // Get data
        let name = eventNameTextField.text
        let dateStart = eventDateStartPicker.date
        let dateEnd = eventDateEndPicker.date
        let alarm = alarmSwitch.on
        let alarmTime = alarmTimePicker.date
        
        // Set data
        event.setValue(name, forKey: "name")
        event.setValue(dateStart, forKey: "dateStart")
        event.setValue(dateEnd, forKey: "dateEnd")
        event.setValue(alarm, forKey: "alarm")
        if alarm {
            event.setValue(alarmTime, forKey: "alarmTime")
        }
        
        // Save event
        var error: NSError?
        if !managedContext.save(&error) {
            assert(false, "Could not save \(error), \(error?.userInfo)")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
            case "SaveEvent":
                saveEvent()
                delegate?.changeEventViewControllerDidSaveEvent()
            case "CancelEvent":
                break
        default:
            break
        }
    }
}


// Delegate protocol
protocol ChangeEventViewControllerDelegate {
    func changeEventViewControllerDidSaveEvent()
}
