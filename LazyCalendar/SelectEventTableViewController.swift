//
//  SelectEventTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/18/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class SelectEventTableViewController: UITableViewController {
    
    // Calendar
    private let calendar = NSCalendar.currentCalendar()
    
    // Date formatter to control date appearances
    private let eventDateFormatter = NSDateFormatter()
    
    // Text field for event name
    @IBOutlet weak var eventNameTextField: UITextField!
    
    // Labels to display event start info
    @IBOutlet weak var eventDateStartMainLabel: UILabel!
    @IBOutlet weak var eventDateStartDetailsLabel: UILabel!
    
    // Labels to display event end info
    @IBOutlet weak var eventDateEndMainLabel: UILabel!
    @IBOutlet weak var eventDateEndDetailsLabel: UILabel!
    
    // Displays alarm time
    @IBOutlet weak var alarmTimeMainLabel: UILabel!
    @IBOutlet weak var alarmTimeDetailsLabel: UILabel!
    
    // Section headers associated with section numbers
    private let sections = ["Name": 0, "Start": 1, "End": 2, "Alarm": 3]
    
    // Keeps track of index paths
    private let indexPaths = ["Name": NSIndexPath(forRow: 0, inSection: 0),
        "Start": NSIndexPath(forRow: 0, inSection: 1), "End": NSIndexPath(forRow: 0, inSection: 2),
        "AlarmToggle": NSIndexPath(forRow: 0, inSection: 3),
        "AlarmDateToggle": NSIndexPath(forRow: 1, inSection: 3),
        "AlarmTimeDisplay": NSIndexPath(forRow: 2, inSection: 3),
        "AlarmTimePicker": NSIndexPath(forRow: 3, inSection: 3)]
    
    private let DEFAULT_CELL_HEIGHT = UITableViewCell().frame.height
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
