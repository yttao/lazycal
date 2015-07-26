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
    
    @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var alarmTimeMainLabel: UILabel!
    @IBOutlet weak var alarmTimeDetailsLabel: UILabel!
    
    @IBOutlet weak var alarmTimeDisplayCell: UITableViewCell!
    
    private var event: FullEvent?
    
    // Section headers associated with section numbers
    private let sections = ["Details": 0, "Alarm": 1]
    
    // Keeps track of index paths
    private let indexPaths = ["Name": NSIndexPath(forRow: 0, inSection: 0),
        "Time": NSIndexPath(forRow: 1, inSection: 0),
        "AlarmToggle": NSIndexPath(forRow: 0, inSection: 1),
        "AlarmTimeDisplay": NSIndexPath(forRow: 1, inSection: 1)]
    
    private let DEFAULT_CELL_HEIGHT = UITableViewCell().frame.height
    
    private let editEventSegueIdentifier = "EditEventSegue"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        reloadData()
    }
    
    
    func reloadData() {
        eventNameLabel.text = event!.name
        dateFormatter.dateFormat = "h:mm a MM/dd/yy"
        eventTimeLabel.text = "\(dateFormatter.stringFromDate(event!.dateStart)) to \(dateFormatter.stringFromDate(event!.dateEnd))"
        if event!.alarm {
            alarmLabel.text = "On"
            alarmTimeDisplayCell.hidden = false
            alarmTimeMainLabel.text = dateFormatter.stringFromDate(event!.alarmTime!)
        }
        else {
            alarmLabel.text = "Off"
            alarmTimeDisplayCell.hidden = true
            alarmTimeMainLabel.text = nil
        }
        alarmTimeMainLabel.sizeToFit()
        tableView.reloadRowsAtIndexPaths([indexPaths["AlarmTimeDisplay"]!], withRowAnimation: .None)
    }
    
    
    func loadEvent(event: FullEvent) {
        self.event = event
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
    }
    
    
    @IBAction func cancelEventEdit(segue: UIStoryboardSegue) {
    }
    
    
    func changeEventViewControllerDidSaveEvent(event: FullEvent) {
        // Update info that was just edited
        reloadData()
        delegate?.selectEventTableViewControllerDidChangeEvent(event)
    }
}

protocol SelectEventTableViewControllerDelegate {
    func selectEventTableViewControllerDidChangeEvent(event: FullEvent)
}
