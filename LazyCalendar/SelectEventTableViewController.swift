//
//  SelectEventTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/18/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class SelectEventTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Calendar
    private let calendar = NSCalendar.currentCalendar()
    
    // Date formatter to control date appearances
    private let dateFormatter = NSDateFormatter()
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var alarmTimeMainLabel: UILabel!
    @IBOutlet weak var alarmTimeDetailsLabel: UILabel!
    
    private var name: String?
    private var dateStart: NSDate?
    private var dateEnd: NSDate?
    private var alarm: Bool?
    private var alarmTime: NSDate?
    
    // Section headers associated with section numbers
    private let sections = ["Details": 0, "Alarm": 1]
    
    // Keeps track of index paths
    private let indexPaths = ["Name": NSIndexPath(forRow: 0, inSection: 0),
        "Time": NSIndexPath(forRow: 1, inSection: 0),
        "AlarmToggle": NSIndexPath(forRow: 0, inSection: 1),
        "AlarmTimeDisplay": NSIndexPath(forRow: 1, inSection: 1)]
    
    private let DEFAULT_CELL_HEIGHT = UITableViewCell().frame.height
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        eventNameLabel.text = name
        dateFormatter.dateFormat = "h:mm a MM/dd/yy"
        eventTimeLabel.text = "\(dateFormatter.stringFromDate(dateStart!)) to \(dateFormatter.stringFromDate(dateEnd!))"
        if alarm! {
            alarmLabel.text = "On"
        }
        else {
            alarmLabel.text = "Off"
        }
    }
    
    
    func loadData(name: String, dateStart: NSDate, dateEnd: NSDate, alarm: Bool, alarmTime: NSDate?) {
        self.name = name
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.alarm = alarm
        self.alarmTime = alarmTime
    }
}
