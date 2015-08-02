//
//  SelectEventTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/18/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import CoreData
import AddressBook

class SelectEventTableViewController: UITableViewController, ChangeEventViewControllerDelegate {
    var delegate: SelectEventTableViewControllerDelegate?
    
    // Date formatter to control date appearances
    private let dateFormatter = NSDateFormatter()
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var alarmTimeMainLabel: UILabel!
    @IBOutlet weak var alarmTimeDetailsLabel: UILabel!
    
    @IBOutlet weak var alarmTimeDisplayCell: UITableViewCell!
    @IBOutlet weak var contactCell: UITableViewCell!
    
    // Selected event, must exist for data to be loaded properly.
    private var event: FullEvent?
    
    // Section headers associated with section numbers
    private let sections = ["Details": 0, "Alarm": 1, "Contacts": 2, "Test": 3]
    
    // Index paths of rows
    private let indexPaths = ["Name": NSIndexPath(forRow: 0, inSection: 0),
        "Time": NSIndexPath(forRow: 1, inSection: 0),
        "AlarmToggle": NSIndexPath(forRow: 0, inSection: 1),
        "AlarmTime": NSIndexPath(forRow: 1, inSection: 1),
        "Contacts": NSIndexPath(forRow: 0, inSection: 2)]
    
    private let editEventSegueIdentifier = "EditEventSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /**
        On view appearance, call `reloadData()` to ensure that the data is updated.
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if event != nil {
            reloadData()
        }
    }
    
    /**
        Refreshes the event information displayed.
    */
    func reloadData() {
        eventNameLabel.text = event!.name
        
        dateFormatter.dateFormat = "h:mm a MM/dd/yy"
        eventTimeLabel.text = "\(dateFormatter.stringFromDate(event!.dateStart)) to \(dateFormatter.stringFromDate(event!.dateEnd))"
        
        if event!.alarm && notificationsEnabled() {
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

        if event!.contacts.count != 0 {
            contactCell.hidden = false
            contactCell.detailTextLabel?.text = "\(event!.contacts.count)"
            contactCell.detailTextLabel?.sizeToFit()
        }
        else {
            contactCell.hidden = true
            contactCell.detailTextLabel?.text = nil
            contactCell.detailTextLabel?.sizeToFit()
        }
        
        tableView.reloadData()
        // Must be called after in case the number of rows changes for contacts.
        if tableView.cellForRowAtIndexPath(indexPaths["Contacts"]!) != nil {
            tableView.reloadRowsAtIndexPaths([indexPaths["Contacts"]!], withRowAnimation: .None)
        }
    }
    
    /**
        Returns a `Bool` indicating whether or not notifications are enabled.
    */
    func notificationsEnabled() -> Bool {
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        if settings.types == UIUserNotificationType.None {
            return false
        }
        return true
    }
    
    /**
        Loads the event data.
    
        :param: event The selected event.
    */
    func loadData(event: FullEvent) {
        self.event = event
    }
    
    func setBackButton(text: String) {
        let backButton = UIBarButtonItem(title: text, style: .Plain, target: nil, action: nil)
        navigationController?.navigationItem.leftBarButtonItem = backButton
        navigationItem.leftBarButtonItem = backButton
    }
    
    /**
        Prepares for segue to event editing by loading event in as initial data.
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == editEventSegueIdentifier {
            let navigationController = segue.destinationViewController as! UINavigationController
            let editEventViewController = navigationController.viewControllers.first as! ChangeEventViewController
            editEventViewController.loadData(event: event!)
            editEventViewController.delegate = self
        }
    }
    
    /**
        The unwind segue for saving event edits.
    */
    @IBAction func saveEventEdit(segue: UIStoryboardSegue) {
    }
    
    /**
        The unwind segue for canceling event edits.
    */
    @IBAction func cancelEventEdit(segue: UIStoryboardSegue) {
    }
}

// MARK: - UITableViewDelegate
extension SelectEventTableViewController: UITableViewDelegate {
    /**
        If there are no rows in the section, header height is 0. Otherwise default header height.
    */
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return 0
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    /**
        Height is default unless it is the alarm time display cell, which can be hidden.
    */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == indexPaths["AlarmTime"] && alarmTimeDisplayCell.hidden {
            return 0
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    /**
        If there are no rows in the section, footer height is 0. Otherwise default footer height.
    */
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return 0
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    /**
        When contacts row is selected, it displays the contacts table view controller that acts as a contact list and contact details view.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == indexPaths["Contacts"]!.section {
            let contactsTableViewController = storyboard!.instantiateViewControllerWithIdentifier("ContactsTableViewController") as! ContactsTableViewController
            
            // Get all contact IDs from the event contacts.
            let contactsSet = event!.contacts as Set
            var contactIDs = [ABRecordID]()
            for contact in contactsSet {
                let c = contact as! Contact
                contactIDs.append(c.id)
            }
            // Load contact IDs into contacts table view controller.
            contactsTableViewController.loadData(contactIDs)
            // Disable searching for new contacts (only allowed when editing event).
            contactsTableViewController.setSearchEnabled(false)
            navigationController?.showViewController(contactsTableViewController, sender: self)
        }
    }
}

// MARK: - UITableViewDataSource
extension SelectEventTableViewController: UITableViewDataSource {
    /**
        Number of sections in the table view.
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    /**
        Returns number of rows for sections.
    
        If there are no contacts, the contacts section has no rows. If the alarm is off, only show one row indicating alarm is off.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sections["Contacts"]! && contactCell.hidden {
            return 0
        }
        else if section == sections["Alarm"]! && alarmTimeDisplayCell.hidden {
            return 1
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    /**
        Returns title for section headers.
    
        If there are no contacts, the contacts header is nil.
    */
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == sections["Contacts"]! && contactCell.hidden  {
            return nil
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
}

// MARK: - ChangeEventViewControllerDelegate
extension SelectEventTableViewController: ChangeEventViewControllerDelegate {
    /**
        Reloads data on event save and informs table view that event was changed.
    
        :param: event The saved event.
    */
    func changeEventViewControllerDidSaveEvent(event: FullEvent) {
        // Update info that was just edited
        reloadData()
        delegate?.selectEventTableViewControllerDidChangeEvent(event)
    }
}

/**
    Delegate protocol for `SelectEventTableViewController`.
*/
protocol SelectEventTableViewControllerDelegate {
    /**
        Informs the delegate that the selected event was modified.
    
        :param: event The modified event.
    */
    func selectEventTableViewControllerDidChangeEvent(event: FullEvent)
}