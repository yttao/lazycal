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
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var alarmTimeMainLabel: UILabel!
    @IBOutlet weak var alarmTimeDetailsLabel: UILabel!
    
    @IBOutlet weak var alarmTimeDisplayCell: UITableViewCell!
    @IBOutlet weak var contactsCell: UITableViewCell!
    @IBOutlet weak var locationsCell: UITableViewCell!
    
    // Selected event, must exist for data to be loaded properly.
    private var event: FullEvent?
    
    // Section headers associated with section numbers
    private let sections = ["Details": 0, "Alarm": 1, "Contacts": 2, "Locations": 3]
    
    // Index paths of rows
    private let indexPaths = ["Name": NSIndexPath(forRow: 0, inSection: 0),
        "Time": NSIndexPath(forRow: 1, inSection: 0),
        "AlarmToggle": NSIndexPath(forRow: 0, inSection: 1),
        "AlarmTime": NSIndexPath(forRow: 1, inSection: 1),
        "Contacts": NSIndexPath(forRow: 0, inSection: 2),
        "Locations": NSIndexPath(forRow: 0, inSection: 3)]
    
    private let segueIdentifier = "EditEventSegue"
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadData:", name: "EventSelected", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadEvent:", name: "EventSaved", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showEventNotification:", name: "EventNotificationReceived", object: nil)
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
        
        if event != nil {
            reloadData()
        }
    }
    
    /**
        Reloads data on event save and informs table view that event was changed.
    
        :param: event The notification informing the view controller that the event was changed.
    */
    func reloadEvent(notification: NSNotification) {
        // Update info that was just edited
        let notifiedEvent = notification.userInfo!["Event"] as! FullEvent
        if self.event!.id == notifiedEvent.id {
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
        
        tableView.beginUpdates()
        if !notificationsEnabled() {
            // If notifications are disabled, the alarm cannot send an alert so it displays "Disabled" and hides the alarm time.
            alarmLabel.text = "Disabled"
            alarmTimeDisplayCell.textLabel?.text = nil
            
            if tableView(tableView, numberOfRowsInSection: sections["Alarm"]!) == super.tableView(tableView, numberOfRowsInSection: sections["Alarm"]!) {
                alarmTimeDisplayCell.hidden = true
                tableView.deleteRowsAtIndexPaths([indexPaths["AlarmTime"]!], withRowAnimation: .None)
            }
            
        }
        else if event!.alarm {
            // If the alarm is enabled, the alarm says "On" and displays the time.
            alarmLabel.text = "On"
            alarmTimeDisplayCell.textLabel?.text = dateFormatter.stringFromDate(event!.alarmTime!)
            
            if tableView(tableView, numberOfRowsInSection: sections["Alarm"]!) == 1 {
                alarmTimeDisplayCell.hidden = false
                tableView.insertRowsAtIndexPaths([indexPaths["AlarmTime"]!], withRowAnimation: .None)
            }
        }
        else {
            // If the alarm is disabled, the alarm says "Off" and hides the time display.
            alarmLabel.text = "Off"
            alarmTimeDisplayCell.textLabel?.text = nil
            
            if tableView(tableView, numberOfRowsInSection: sections["Alarm"]!) == super.tableView(tableView, numberOfRowsInSection: sections["Alarm"]!) {
                alarmTimeDisplayCell.hidden = true
                tableView.deleteRowsAtIndexPaths([indexPaths["AlarmTime"]!], withRowAnimation: .None)
            }
            
        }
        alarmTimeDisplayCell.textLabel?.sizeToFit()

        //tableView.beginUpdates()
        if event!.contacts.count > 0 {
            // Show contacts cell with number of contacts in detail label if the event has at least one contact.
            contactsCell.detailTextLabel?.text = "\(event!.contacts.count)"
            
            // If contacts row has been removed, add row back.
            if self.tableView(tableView, numberOfRowsInSection: sections["Contacts"]!) == 0 {
                contactsCell.hidden = false
                tableView.insertRowsAtIndexPaths([indexPaths["Contacts"]!], withRowAnimation: .None)
            }
        }
        else {
            // Hide contacts cell if the event has no contacts.
            contactsCell.detailTextLabel?.text = nil
            
            // If contacts cell exists, delete row.
            if tableView(tableView, numberOfRowsInSection: sections["Contacts"]!) == 1 {
                contactsCell.hidden = true
                tableView.deleteRowsAtIndexPaths([indexPaths["Contacts"]!], withRowAnimation: .None)
            }
        }
        contactsCell.detailTextLabel?.sizeToFit()
        
        if event!.locations.count > 0 {
            // Show locations cell with number of locations in detail label if the event has at least one location.
            locationsCell.detailTextLabel?.text = "\(event!.locations.count)"
            
            // If locations row has been removed, add row back.
            if tableView(tableView, numberOfRowsInSection: sections["Locations"]!) == 0 {
                locationsCell.hidden = false
                tableView.insertRowsAtIndexPaths([indexPaths["Locations"]!], withRowAnimation: .None)
            }
        }
        else {
            // Hide locations cell if the event has no locations.
            locationsCell.detailTextLabel?.text = nil
            
            // If locations cell exists, delete row.
            if tableView(tableView, numberOfRowsInSection: sections["Locations"]!) == 1 {
                locationsCell.hidden = true
                tableView.deleteRowsAtIndexPaths([indexPaths["Locations"]!], withRowAnimation: .None)
            }
        }
        locationsCell.detailTextLabel?.sizeToFit()
        tableView.endUpdates()
        
        tableView.reloadData()
    }
    
    /**
        Returns a `Bool` indicating whether or not notifications are enabled.
    
        Notifications are enabled if alerts, badges, and sound are enabled.
    */
    private func notificationsEnabled() -> Bool {
        let notificationTypes = UIApplication.sharedApplication().currentUserNotificationSettings().types
        if notificationTypes.rawValue & UIUserNotificationType.Alert.rawValue != 0 && notificationTypes.rawValue & UIUserNotificationType.Badge.rawValue != 0 && notificationTypes.rawValue & UIUserNotificationType.Sound.rawValue != 0 {
            return true
        }
        return false
    }
    
    /**
        Loads the event data.
    
        :param: notification The notification that an event was selected.
    */
    func loadData(notification: NSNotification) {
        self.event = notification.userInfo!["Event"] as? FullEvent
    }
    
    private func showContactsViewController() {
        let contactsTableViewController = storyboard!.instantiateViewControllerWithIdentifier("ContactsTableViewController") as! ContactsTableViewController
        
        // Get all contact IDs from the event contacts.
        let contactsSet = event!.contacts as Set
        var contactIDs = [ABRecordID]()
        for contact in contactsSet {
            let contact = contact as! Contact
            contactIDs.append(contact.id)
        }
        // Load contact IDs into contacts table view controller.
        contactsTableViewController.loadData(contactIDs)
        // Disable searching for new contacts.
        contactsTableViewController.setEditingEnabled(false)
        
        navigationController!.showViewController(contactsTableViewController, sender: self)
    }
    
    private func showLocationsViewController() {
        let locationsViewController = storyboard!.instantiateViewControllerWithIdentifier("LocationsViewController") as! LocationsViewController
        
        // Make array of map items from event points of interest.
        var mapItems = [MapItem]()
        for location in event!.locations {
            let location = location as! Location
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let name = location.name
            let address = location.address
            let mapItem = MapItem(coordinate: coordinate, name: name, address: address)
            mapItems.append(mapItem)
        }
        
        // Load map items into locations view controller.
        locationsViewController.loadData(mapItems)
        // Disable searching for new locations.
        locationsViewController.setEditingEnabled(false)
        
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
            editEventViewController.loadData(event: event!)
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
    
    /**
        Show an alert for the event notification. The alert provides two options: "OK" and "View Event". Tap "OK" to dismiss the alert. Tap "View Event" to show event details.
    
        This is only called if this view controller is loaded and currently visible.
    
        :param: notification The notification from the subject to the observer.
    */
    func showEventNotification(notification: NSNotification) {
        if isViewLoaded() && view?.window != nil {
            let localNotification = notification.userInfo!["LocalNotification"] as! UILocalNotification
            
            let alertController = UIAlertController(title: "\(localNotification.alertTitle)", message: "\(localNotification.alertBody!)", preferredStyle: .Alert)
            
            let viewEventAlertAction = UIAlertAction(title: "View Event", style: .Default, handler: {
                (action: UIAlertAction!) in
                let selectEventNavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("SelectEventNavigationController") as! UINavigationController
                let selectEventTableViewController = selectEventNavigationController.viewControllers.first as! SelectEventTableViewController
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext!
                
                let id = localNotification.userInfo!["id"] as! String
                let requirements = "(id == %@)"
                let predicate = NSPredicate(format: requirements, id)
                
                let fetchRequest = NSFetchRequest(entityName: "FullEvent")
                fetchRequest.predicate = predicate
                
                var error: NSError? = nil
                let results = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [FullEvent]
                
                if results != nil && results!.count > 0 {
                    let event = results!.first!
                    NSNotificationCenter.defaultCenter().postNotificationName("EventSelected", object: self, userInfo: ["Event": event])
                }
                
                self.showViewController(selectEventTableViewController, sender: self)
            })
            
            let okAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            
            alertController.addAction(viewEventAlertAction)
            alertController.addAction(okAlertAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDelegate
extension SelectEventTableViewController: UITableViewDelegate {
    /**
        If there are no rows in the section, header height is 0. Otherwise default header height.
    */
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return CGFloat(0)
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    /**
        If there are no rows in the section, header view is nil.
    */
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return nil
        }
        return super.tableView(tableView, viewForHeaderInSection: section)
    }
    
    /**
        If there are no rows in the section, footer view is nil.
    */
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return nil
        }
        return super.tableView(tableView, viewForFooterInSection: section)
    }
    
    /**
        Height is default unless it is the alarm time display cell, which can be hidden.
    */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == indexPaths["AlarmTime"] && alarmTimeDisplayCell.hidden {
            return CGFloat(0)
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    /**
        If there are no rows in the section, footer height is 0. Otherwise default footer height.
    */
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return CGFloat(0)
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    /**
        When contacts row is selected, it displays the contacts table view controller that acts as a contact list and contact details view. When locations row is selected, it displays the locations view controller that acts as the locations list and map view.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // If contacts row selected
        if indexPath.section == indexPaths["Contacts"]!.section {
            showContactsViewController()
        }
        // If locations row selected, initialize locations view controller
        else if indexPath.section == indexPaths["Locations"]!.section {
            showLocationsViewController()
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
        else if section == sections["Locations"]! && locationsCell.hidden {
            return 0
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
}