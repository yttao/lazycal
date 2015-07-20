//
//  SelectEventTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/18/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import CoreData

class SelectEventTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, ChangeEventViewControllerDelegate {
    
    var delegate: SelectEventTableViewControllerDelegate?
    
    // Date formatter to control date appearances
    private let dateFormatter = NSDateFormatter()
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var alarmTimeMainLabel: UILabel!
    @IBOutlet weak var alarmTimeDetailsLabel: UILabel!
    
    private var event: NSManagedObject?
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
    
    private let editEventSegueIdentifier = "EditEventSegue"
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        reloadData()
    }
    
    
    func reloadData() {
        name = event!.valueForKey("name") as? String
        dateStart = event!.valueForKey("dateStart") as? NSDate
        dateEnd = event!.valueForKey("dateEnd") as? NSDate
        alarm = event!.valueForKey("alarm") as? Bool
        alarmTime = event!.valueForKey("alarmTime") as? NSDate
        
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
    
    
    func loadEventDetails(event: NSManagedObject, name: String, dateStart: NSDate, dateEnd: NSDate, alarm: Bool, alarmTime: NSDate?) {
        self.event = event
        self.name = name
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.alarm = alarm
        self.alarmTime = alarmTime
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case editEventSegueIdentifier:
                // Find view controller for editing events
                let navigationController = segue.destinationViewController as! UINavigationController
                let editEventViewController = navigationController.viewControllers.first as! ChangeEventViewController
                // Set pre-existing event
                editEventViewController.loadData(event: event!)
                editEventViewController.delegate = self
            default:
                break
            }
        }
    }
    
    
    @IBAction func saveEventEdit(segue: UIStoryboardSegue) {
        println("Event edited")
    }
    
    
    @IBAction func cancelEventEdit(segue: UIStoryboardSegue) {
        println("Event edit cancelled")
    }
    
    
    func changeEventViewControllerDidSaveEvent(event: NSManagedObject) {
        // Update info that was just edited
        reloadData()
        delegate?.selectEventTableViewControllerDidChangeEvent(event)
    }
}

protocol SelectEventTableViewControllerDelegate {
    func selectEventTableViewControllerDidChangeEvent(event: NSManagedObject)
}
