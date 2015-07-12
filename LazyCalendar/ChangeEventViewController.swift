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
    
    // Index path of currently selected field
    private var selectedIndexPath: NSIndexPath?
    
    // Number of fields to fill in for event info
    private let NUM_FIELDS = 3
    
    
    
    // Initialization
    required init(coder: NSCoder) {
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
        return NUM_FIELDS
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("***Selected: \(indexPath)***")
        println("Selected index: \(selectedIndexPath)")
        // Take action based on what section was chosen
        switch indexPath.section {
        case 0:
            selectedIndexPath = indexPath
            
            tableView.reloadData()
            eventNameTextField.userInteractionEnabled = true
            eventNameTextField.becomeFirstResponder()
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        case 1:
            selectedIndexPath = indexPath
            
            // Hide date start labels
            eventDateStartMainLabel.hidden = true
            eventDateStartDetailsLabel.hidden = true
            
            // Show date start picker
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.contentView.addSubview(eventDateStartPicker)
            cell.contentView.didAddSubview(eventDateStartPicker)
            
            // Recalculate height to display date picker
            tableView.reloadData()
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        case 2:
            selectedIndexPath = indexPath
            
            // Hide date end labels
            eventDateEndMainLabel.hidden = true
            eventDateEndDetailsLabel.hidden = true
            
            // Show date end picker
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.contentView.addSubview(eventDateEndPicker)
            cell.contentView.didAddSubview(eventDateEndPicker)
            
            tableView.reloadData()
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        default:
            break
        }
    }
    
    
    // Called on cell deselection (when a different cell is selected)
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        println("***Deselected: \(indexPath)***")
        switch indexPath.section {
            // If deselecting event name field, text field stops being first responder and disables
            // user interaction with it.
            case 0:
                eventNameTextField.userInteractionEnabled = false
                eventNameTextField.resignFirstResponder()
            // If deselecting date start field, hide date start picker and show labels
            case 1:
                let cell = tableView.cellForRowAtIndexPath(indexPath)!
                eventDateStartPicker.removeFromSuperview()
                eventDateStartMainLabel.hidden = false
                eventDateStartDetailsLabel.hidden = false
            // If deselecting date end field, hide date end picker and show labels
            case 2:
                let cell = tableView.cellForRowAtIndexPath(indexPath)!
                eventDateEndPicker.removeFromSuperview()
                eventDateEndMainLabel.hidden = false
                eventDateEndDetailsLabel.hidden = false
            default:
                break
        }
    }
    
    
    // Calculates height for rows
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
            // Event name field has default height
            case 0:
                let cell = UITableViewCell()
                return cell.frame.height
            // Event date start field changes height based on if it is selected or not
            case 1:
                // If selected, height is date picker height
                if selectedIndexPath == indexPath {
                    let datePickerHeight = eventDateStartPicker.frame.size.height
                    return CGFloat(datePickerHeight)
                }
                // Otherwise default height
                else {
                    let cell = UITableViewCell()
                    return cell.frame.height
                }
            // Event date end field changes height based on if it is selected or not
            case 2:
                // If selected, height is date picker height
                if selectedIndexPath == indexPath {
                    let datePickerHeight = eventDateEndPicker.frame.size.height
                    return CGFloat(datePickerHeight)
                }
                // Otherwise default height
                else {
                    let cell = UITableViewCell()
                    return cell.frame.height
                }
            default:
                let cell = UITableViewCell()
                return cell.frame.height
        }
    }
}
