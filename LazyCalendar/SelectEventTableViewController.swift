//
//  SelectEventTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/18/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit
import AddressBook

class SelectEventTableViewController: UITableViewController {
    // Date formatter to control date appearances
    private let dateFormatter = NSDateFormatter()
    
    @IBOutlet weak var alarmTimeDisplayCell: UITableViewCell!
    @IBOutlet weak var contactsCell: UITableViewCell!
    @IBOutlet weak var locationsCell: UITableViewCell!
    @IBOutlet weak var weatherCell: UILabel!
    
    // Selected event, must exist for data to be loaded properly.
    var event: LZEvent!
    
    // Section headers associated with section numbers
    private let sections = ["Details": 0, "Alarm": 1, "Contacts": 2, "Locations": 3]
    
    // Index paths of rows
    private let indexPaths = ["Name": NSIndexPath(forRow: 0, inSection: 0),
        "Time": NSIndexPath(forRow: 1, inSection: 0),
        "AlarmToggle": NSIndexPath(forRow: 0, inSection: 1),
        "AlarmTime": NSIndexPath(forRow: 1, inSection: 1),
        "Contacts": NSIndexPath(forRow: 0, inSection: 2),
        "Locations": NSIndexPath(forRow: 0, inSection: 3),
        "Weather": NSIndexPath(forRow: 1, inSection: 3)]
    
    private let segueIdentifier = "EditEventSegue"
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadData:", name: "EventSelected", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadEvent:", name: "EventSaved", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showEventNotification:", name: "EventNotificationReceived", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadData", name: "applicationBecameActive", object: nil)
    }
    
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
        
        reloadData()
    }
    
    /**
        Reloads data on event save and informs table view that event was changed.
    
        :param: event The notification informing the view controller that the event was changed.
    */
    func reloadEvent(notification: NSNotification) {
        // Update info that was just edited
        let notifiedEvent = notification.userInfo!["Event"] as! LZEvent
        if event.id == notifiedEvent.id {
            reloadData()
        }
    }
    
    /**
        Refreshes the event information displayed.
    */
    func reloadData() {
        let eventNameCell = tableView(tableView, cellForRowAtIndexPath: indexPaths["Name"]!)
        eventNameCell.textLabel?.text = event.name
        
        let eventTimeCell = tableView(tableView, cellForRowAtIndexPath: indexPaths["Time"]!)
        dateFormatter.dateFormat = "h:mm a MM/dd/yy"
        eventTimeCell.textLabel?.text = dateFormatter.stringFromDateInterval(fromDate: event.dateStart, toDate: event.dateEnd, fromTimeZone: event.dateStartTimeZone, toTimeZone: event.dateEndTimeZone)
        
        // Start of cell insertion/deletion code.
        
        // Disable animations (to prevent insert/delete cell animations).
        UIView.setAnimationsEnabled(false)
        
        tableView.beginUpdates()
        
        // Handle alarm cells.
        let alarmCell = tableView(tableView, cellForRowAtIndexPath: indexPaths["AlarmToggle"]!)
        if !notificationsEnabled() {
            // If alarm notifications are disabled
            
            // Hide the alarm time display cell if it's visible.
            if tableView(tableView, numberOfRowsInSection: sections["Alarm"]!) == super.tableView(tableView, numberOfRowsInSection: sections["Alarm"]!) {
                alarmTimeDisplayCell.hidden = true
                tableView.deleteRowsAtIndexPaths([indexPaths["AlarmTime"]!], withRowAnimation: .None)
            }
            
            // If notifications are disabled, the alarm cannot send an alert.
            
            // The alarm is disabled, so it says "Disabled".
            alarmCell.detailTextLabel?.text = "Disabled"
            
            // Hide the alarm time.
            alarmTimeDisplayCell.textLabel?.text = " "
            alarmTimeDisplayCell.detailTextLabel?.text = " "
        }
        else if event.alarm {
            // If the alarm is on
            
            // Show the alarm time display cell if it's hidden.
            if tableView(tableView, numberOfRowsInSection: sections["Alarm"]!) != super.tableView(tableView, numberOfRowsInSection: sections["Alarm"]!) {
                alarmTimeDisplayCell.hidden = false
                tableView.insertRowsAtIndexPaths([indexPaths["AlarmTime"]!], withRowAnimation: .None)
            }
            
            // The alarm says "On".
            alarmCell.detailTextLabel?.text = "On"
            
            // Display the alarm time.
            
            // The alarm main label shows the alarm date.
            dateFormatter.dateFormat = "MMM dd, yyyy"
            alarmTimeDisplayCell.textLabel?.text = dateFormatter.stringFromDate(event.alarmTime!)
            
            // The alarm detail label shows the alarm time.
            dateFormatter.dateFormat = "h:mm a"
            alarmTimeDisplayCell.detailTextLabel?.text = dateFormatter.stringFromDate(event.alarmTime!)
        }
        else {
            // If the alarm is off
            
            // Hide the alarm time display cell if it's visible.
            if tableView(tableView, numberOfRowsInSection: sections["Alarm"]!) == super.tableView(tableView, numberOfRowsInSection: sections["Alarm"]!) {
                alarmTimeDisplayCell.hidden = true
                tableView.deleteRowsAtIndexPaths([indexPaths["AlarmTime"]!], withRowAnimation: .None)
            }
            
            // The alarm says "Off".
            alarmCell.detailTextLabel?.text = "Off"
            
            // Hide the alarm time.
            alarmTimeDisplayCell.textLabel?.text = " "
            alarmTimeDisplayCell.detailTextLabel?.text = " "
        }
        alarmCell.detailTextLabel?.sizeToFit()
        alarmTimeDisplayCell.detailTextLabel?.sizeToFit()

        // Handle contacts cell.
        if event.contacts.count > 0 {
            // If the event has contacts
            
            // Show the contacts cell if it's hidden.
            if tableView(tableView, numberOfRowsInSection: sections["Contacts"]!) != super.tableView(tableView, numberOfRowsInSection: sections["Contacts"]!) {
                contactsCell.hidden = false
                tableView.insertRowsAtIndexPaths([indexPaths["Contacts"]!], withRowAnimation: .None)
            }
            
            // Show the number of contacts.
            contactsCell.detailTextLabel?.text = "\(event.contacts.count)"
        }
        else {
            // If the event does not have contacts
            
            // Hide the contacts cell if it's visible.
            if tableView(tableView, numberOfRowsInSection: sections["Contacts"]!) == super.tableView(tableView, numberOfRowsInSection: sections["Contacts"]!) {
                contactsCell.hidden = true
                tableView.deleteRowsAtIndexPaths([indexPaths["Contacts"]!], withRowAnimation: .None)
            }
            
            // Hide the number of contacts.
            contactsCell.detailTextLabel?.text = " "
        }
        contactsCell.detailTextLabel?.sizeToFit()
        
        // Handle locations cell.
        if event.locations.count > 0 {
            // If the event has locations
            
            // Show the locations cell if it's hidden.
            if locationsCell.hidden {
                locationsCell.hidden = false
                tableView.insertRowsAtIndexPaths([indexPaths["Locations"]!], withRowAnimation: .None)
            }
            
            // Show the number of locations.
            locationsCell.detailTextLabel?.text = "\(event.locations.count)"
        }
        else {
            // If the event does not have locations
            
            // Hide the locations cell if it's visible.
            if !locationsCell.hidden {
                locationsCell.hidden = true
                tableView.deleteRowsAtIndexPaths([indexPaths["Locations"]!], withRowAnimation: .None)
            }
            
            // Hide locations cell if the event has no locations.
            locationsCell.detailTextLabel?.text = " "
        }
        locationsCell.detailTextLabel?.sizeToFit()
        
        if event.weather {
            if weatherCell.hidden {
                weatherCell.hidden = false
                tableView.insertRowsAtIndexPaths([indexPaths["Weather"]!], withRowAnimation: .None)
            }
        }
        else {
            if !weatherCell.hidden {
                weatherCell.hidden = true
                tableView.deleteRowsAtIndexPaths([indexPaths["Weather"]!], withRowAnimation: .None)
            }
        }
        
        // End of cell insertion/deletion code.
        
        tableView.endUpdates()
        
        // Re-enable animations.
        UIView.setAnimationsEnabled(true)
        
        // Reload table data.
        tableView.reloadData()
    }
    
    /**
        Loads the event data.
    
        This method is called if this view controller is brought up from a local notification.
    
        :param: notification The notification that an event was selected.
    */
    func loadData(notification: NSNotification) {
        event = notification.userInfo!["Event"] as! LZEvent
    }
    
    /**
        Shows the `ContactsTableViewController` for this event.
    
        This method is called when the contact cell is selected.
    */
    private func showContactsTableViewController() {
        let contactsTableViewController = storyboard!.instantiateViewControllerWithIdentifier("ContactsTableViewController") as! ContactsTableViewController
        
        // Load event into contacts table view controller.
        contactsTableViewController.loadData(event: event)
        // Disable searching for new contacts.
        contactsTableViewController.editingEnabled = false
        
        navigationController!.showViewController(contactsTableViewController, sender: self)
    }
    
    private func showLocationsViewController() {
        let locationsViewController = storyboard!.instantiateViewControllerWithIdentifier("LocationsViewController") as! LocationsViewController
        
        // Load event into locations table view controller.
        locationsViewController.loadData(event: event)
        // Disable searching for new locations.
        locationsViewController.editingEnabled = false
        
        // Show locations view controller
        navigationController!.showViewController(locationsViewController, sender: self)
    }
    
    /**
        Prepares for segue to event editing by loading event in as initial data.
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueIdentifier {
            let navigationController = segue.destinationViewController as! UINavigationController
            let editEventViewController = navigationController.viewControllers.first as! ChangeEventViewController
            editEventViewController.loadData(event: event)
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
    // MARK: - Methods for header and footer views.
    
    /**
        If there are no rows in the section, header height is 0. Otherwise default header height.
    */
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return CGFloat(Math.epsilon)
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    /**
        If there are no rows in the section, footer height is 0. Otherwise default footer height.
    */
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return CGFloat(Math.epsilon)
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    /**
        If there are no rows in the section, header view is nil.
    */
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return UIView(frame: CGRectZero)
        }
        return super.tableView(tableView, viewForHeaderInSection: section)
    }
    
    /**
        If there are no rows in the section, footer view is nil.
    */
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return UIView(frame: CGRectZero)
        }
        return super.tableView(tableView, viewForFooterInSection: section)
    }
    
    /**
        Height is default unless it is the alarm time display cell, which can be hidden.
    */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == indexPaths["AlarmTime"] && alarmTimeDisplayCell.hidden {
            return CGFloat(Math.epsilon)
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    /**
        When contacts row is selected, it displays the contacts table view controller that acts as a contact list and contact details view. When locations row is selected, it displays the locations view controller that acts as the locations list and map view.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Contacts row selected
        if indexPath.section == indexPaths["Contacts"]!.section {
            if addressBookAccessible() {
                // If address book can be accessed, show contacts view controller.
                showContactsTableViewController()
            }
            else {
                // Otherwise display alert stating address book can't be accessed.
                displayAddressBookInaccessibleAlert()
            }
        }
        else if indexPath.section == indexPaths["Locations"]!.section {
            if locationAccessible() {
                // If user location can be accessed, show locations view controller.
                showLocationsViewController()
            }
            else {
                // Otherwise display alert stating location can't be accessed.
                displayLocationInaccessibleAlert()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension SelectEventTableViewController: UITableViewDataSource {
    /**
        Returns number of rows for sections.
    
        If there are no contacts, the contacts section has no rows. If the alarm is off, only show one row indicating alarm is off.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sections["Alarm"]! && alarmTimeDisplayCell.hidden {
            return 1
        }
        else if section == sections["Contacts"]! && contactsCell.hidden {
            return 0
        }
        else if section == sections["Locations"]! {
            if locationsCell.hidden && weatherCell.hidden {
                return 0
            }
            else if locationsCell.hidden || weatherCell.hidden {
                return 1
            }
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    /**
        Returns title for section headers.
    
        If there are no contacts, the contacts header is nil.
    */
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == sections["Contacts"]! && contactsCell.hidden  {
            return nil
        }
        else if section == sections["Locations"]! && locationsCell.hidden {
            return nil
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        return cell
    }
}