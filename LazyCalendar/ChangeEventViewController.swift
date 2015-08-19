//
//  ChangeEventViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/9/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import AddressBook
import AddressBookUI

class ChangeEventViewController: UITableViewController {
    // Event data to store
    private var name: String?
    private var dateStart: NSDate!
    private var dateEnd: NSDate!
    private var alarm: Bool = false
    private var alarmTime: NSDate?
    private var contactIDs: [ABRecordID]?
    private var mapItems: [MapItem]?
    
    private var event: FullEvent?
    
    // Date formatter to control date appearances
    private let dateFormatter = NSDateFormatter()
    
    // Date start and end pickers to decide time interval
    @IBOutlet weak var dateStartPicker: UIDatePicker!
    @IBOutlet weak var dateEndPicker: UIDatePicker!
    
    // Text field for event name
    @IBOutlet weak var nameTextField: UITextField!
    
    // Toggles alarm option on/off
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var alarmDateSwitch: UISwitch!
    
    // Picks alarm time
    @IBOutlet weak var alarmTimePicker: UIDatePicker!
    
    // Table cells
    @IBOutlet weak var dateStartPickerCell: UITableViewCell!
    @IBOutlet weak var dateEndPickerCell: UITableViewCell!
    @IBOutlet weak var alarmDateToggleCell: UITableViewCell!
    @IBOutlet weak var alarmTimeDisplayCell: UITableViewCell!
    @IBOutlet weak var alarmTimePickerCell: UITableViewCell!
    
    // Section headers associated with section numbers
    private let sections = ["Name": 0, "Start": 1, "End": 2, "Alarm": 3, "Contacts": 4, "Locations": 5]
    
    // Keeps track of index paths
    private let indexPaths = ["Name": NSIndexPath(forRow: 0, inSection: 0),
        "Start": NSIndexPath(forRow: 0, inSection: 1),
        "StartPicker": NSIndexPath(forRow: 1, inSection: 1),
        "End": NSIndexPath(forRow: 0, inSection: 2),
        "EndPicker": NSIndexPath(forRow: 1, inSection: 2),
        "AlarmToggle": NSIndexPath(forRow: 0, inSection: 3),
        "AlarmDateToggle": NSIndexPath(forRow: 1, inSection: 3),
        "AlarmTimeDisplay": NSIndexPath(forRow: 2, inSection: 3),
        "AlarmTimePicker": NSIndexPath(forRow: 3, inSection: 3),
        "Contacts": NSIndexPath(forRow: 0, inSection: 4),
        "Locations": NSIndexPath(forRow: 0, inSection: 5)]
    
    // Currently selected index path
    private var selectedIndexPath: NSIndexPath?
    
    private var addressBookRef: ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue()
    
    private let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    // MARK: - Methods for initializing view controller.
    
    /**
        On initialization, get address book.
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Observer for when notification pops up
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showEventNotification:", name: "EventNotificationReceived", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAlarmSwitchEnabled", name: "applicationBecameActive", object: nil)
    }
    
    /**
        Provides setup information for the initial data, before the user changes anything.
    
        On view load:
        * Set the table view delegate and data source.
        * Set date start picker date to the selected date (or the first day of the month if none are selected) and the picker time to the current time (in hours and minutes). Set date end picker time to show one hour after the date start picker date and time.
        * Disable the event name text field. This is done to allow proper cell selection (which does not work properly if the text field is selectable.
        * Add action targets that are informed when events occur.
        * Format the event start and end labels. The main labels show the format: month day, year. The details labels show the format: hour:minutes period.
        * Default set the alarm switches off and the alarm time picker to the initial date start.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set tableview delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add targets for updates
        addTargets()
        
        // Disable text field user interaction, needed to allow proper table view row selection
        nameTextField.userInteractionEnabled = false
        nameTextField.autocapitalizationType = .Sentences
        nameTextField.delegate = self
        
        // Using information from loadData:, set initial values for UI elements.
        nameTextField.text = name
        dateStartPicker.date = dateStart
        dateEndPicker.date = dateEnd
        alarmSwitch.on = alarm
        alarmDateSwitch.on = false
        alarmTimePicker.date = alarmTime!
    }
    
    /**
        On view appearance, update all information in table view.
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    /**
        Reloads the table view data.
    */
    func reloadData() {
        updateDateStart()
        updateDateEnd()
        updateAlarmSwitchEnabled()
        updateAlarm()
        updateContactsLabel()
        updateLocationsLabel()
        tableView.reloadData()
    }
    
    /**
        Adds the necessary targets for actions.
    */
    func addTargets() {
        nameTextField.addTarget(self, action: "updateName", forControlEvents: .EditingChanged)
        dateStartPicker.addTarget(self, action: "updateDateStart", forControlEvents: .ValueChanged)
        dateEndPicker.addTarget(self, action: "updateDateEnd", forControlEvents: .ValueChanged)
        alarmSwitch.addTarget(self, action: "selectAlarm", forControlEvents: .ValueChanged)
        alarmTimePicker.addTarget(self, action: "updateAlarmTime", forControlEvents: .ValueChanged)
    }
    
    // MARK: - Methods for initializing data.
    
    /**
        Initializes data with a start date.
    
        :param: The date to load initial data.
    */
    func loadData(#dateStart: NSDate) {
        name = nil
        self.dateStart = dateStart
        let hour = NSTimeInterval(3600)
        dateEnd = dateStart.dateByAddingTimeInterval(hour)
        alarm = false
        alarmTime = dateStart
        contactIDs = nil
    }
    
    /**
        Initializes data with a pre-existing event.
    
        :param: event The event to edit.
    */
    func loadData(#event: FullEvent) {
        self.event = event
        name = event.name
        dateStart = event.dateStart
        dateEnd = event.dateEnd
        alarm = event.alarm
        
        let test = event.dateStart
        // Set alarm time if it is available, otherwise it is the default alarm time.
        if event.alarmTime != nil {
            alarmTime = event.alarmTime
        }
        else {
            alarmTime = dateStart
        }
        
        // Load Contacts as ABRecordIDs
        let storedContacts = event.contacts.allObjects as! [Contact]
        contactIDs = storedContacts.map({
            return $0.id
        })
        
        // Load Locations as MapItems
        let storedLocations = event.locations.allObjects as! [Location]
        mapItems = storedLocations.map({
            return MapItem(location: $0)
        })
    }
    
    // MARK: - Methods related to updating data.
    
    /**
        Update event name.
    */
    func updateName() {
        name = nameTextField.text
    }
    
    /**
        Update date start info.
    */
    func updateDateStart() {
        dateStart = dateStartPicker.date
        updateDateStartLabels()
        
        updateDateEndPickerMinimumDate()
        
        updateAlarm()
    }
    
    /**
        Update the date start labels.
    */
    func updateDateStartLabels() {
        let dateStartCell = tableView(tableView, cellForRowAtIndexPath: indexPaths["Start"]!)
        
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateStartCell.textLabel?.text = dateFormatter.stringFromDate(dateStart)
        
        dateFormatter.dateFormat = "h:mm a"
        dateStartCell.detailTextLabel?.text = dateFormatter.stringFromDate(dateStart)
    }
    
    /**
        Update date end info.
    */
    func updateDateEnd() {
        dateEnd = dateEndPicker.date
        updateDateEndLabels()
    }
    
    /**
        Updates the date end labels.
    */
    func updateDateEndLabels() {
        let dateEndCell = tableView(tableView, cellForRowAtIndexPath: indexPaths["End"]!)
        
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateEndCell.textLabel?.text = dateFormatter.stringFromDate(dateEnd)
        
        dateFormatter.dateFormat = "h:mm a"
        dateEndCell.detailTextLabel?.text = dateFormatter.stringFromDate(dateEnd)
    }
    
    /**
        Updates the date end picker minimum date so that it is not before the date start.
    
        The date end picker should not be able to choose a date before the date start, so it should have a lower limit placed on the date it can choose.
    */
    func updateDateEndPickerMinimumDate() {
        let originalDate = dateEndPicker.date
        dateEndPicker.minimumDate = dateStart

        // If the old date end comes after the new date start, change the old date end to equal the new date start.
        if originalDate.compare(dateStart) == .OrderedAscending {
            resetDateEndPickerDate()
        }
    }
    
    /**
        Resets the date end to the date start.
    */
    func resetDateEndPickerDate() {
        dateEndPicker.date = dateStart
        updateDateEnd()
    }
    
    /**
        Updates whether or not the alarm switch is enabled.
    
        The alarm switch can be toggled if user notifications are allowed. Otherwise, the alarm switch cannot be toggled.
    */
    func updateAlarmSwitchEnabled() {
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        if notificationsEnabled() {
            alarmSwitch.userInteractionEnabled = true
        }
        else {
            alarmSwitch.on = false
            alarm = false
            alarmSwitch.userInteractionEnabled = false
        }
        updateAlarmOptions()
    }
    
    /**
        When the alarm switch is pressed, the alarm cell is selected and the alarm is updated.
    */
    func selectAlarm() {
        if selectedIndexPath != nil && selectedIndexPath != indexPaths["AlarmToggle"]! {
            deselectRowAtIndexPath(selectedIndexPath!)
        }
        selectedIndexPath = indexPaths["AlarmToggle"]
        
        updateAlarm()
    }
    
    /**
        Updates the alarm and the alarm options.
    */
    func updateAlarm() {
        alarm = alarmSwitch.on
        
        updateAlarmTime()
        updateAlarmOptions()
    }
    
    /**
        Updates if the alarm options are shown or not.
    
        If the alarm is on, alarm options are shown. If the alarm is off, alarm options are hidden.
    */
    func updateAlarmOptions() {
        if alarm {
            showMoreAlarmOptions()
        }
        else {
            resetAlarmTime()
            showFewerAlarmOptions()
        }
    }
    
    /**
        Update the alarm time if the alarm is off. The default alarm time is the date start.
    */
    func resetAlarmTime() {
        alarmTimePicker.date = dateStart
        updateAlarmTime()
    }
    
    /**
        Show more alarm options.
    */
    func showMoreAlarmOptions() {
        tableView.beginUpdates()
        
        if alarmDateToggleCell.hidden {
            tableView.insertRowsAtIndexPaths([indexPaths["AlarmDateToggle"]!], withRowAnimation: .Automatic)
        }
        if alarmTimeDisplayCell.hidden {
            tableView.insertRowsAtIndexPaths([indexPaths["AlarmTimeDisplay"]!], withRowAnimation: .Automatic)
        }
        /*if alarmTimePickerCell.hidden {
            tableView.insertRowsAtIndexPaths([indexPaths["AlarmTimePicker"]!], withRowAnimation: .Automatic)
        }*/
        
        alarmDateToggleCell.hidden = false
        alarmTimeDisplayCell.hidden = false
        //alarmTimePickerCell.hidden = false
        
        tableView.endUpdates()
    }
    
    /**
        Show fewer alarm options.
    */
    func showFewerAlarmOptions() {
        tableView.beginUpdates()
        
        if !alarmDateToggleCell.hidden {
            tableView.deleteRowsAtIndexPaths([indexPaths["AlarmDateToggle"]!], withRowAnimation: .Automatic)
        }
        if !alarmTimeDisplayCell.hidden {
            tableView.deleteRowsAtIndexPaths([indexPaths["AlarmTimeDisplay"]!], withRowAnimation: .Automatic)
        }
        if !alarmTimePickerCell.hidden {
            tableView.deleteRowsAtIndexPaths([indexPaths["AlarmTimePicker"]!], withRowAnimation: .Automatic)
        }
        
        // Hide options
        alarmDateToggleCell!.hidden = true
        alarmTimeDisplayCell!.hidden = true
        alarmTimePickerCell!.hidden = true
        
        tableView.endUpdates()
    }
    
    /**
        Update alarm time.
    */
    func updateAlarmTime() {
        alarmTime = alarmTimePicker.date
        updateAlarmTimeLabels()
    }
    
    /**
        Updates the alarm time display.
    */
    func updateAlarmTimeLabels() {
        let alarmTimeCell = alarmTimeDisplayCell
        
        dateFormatter.dateFormat = "MMM dd, yyyy"
        alarmTimeDisplayCell.textLabel?.text = dateFormatter.stringFromDate(alarmTime!)
        
        dateFormatter.dateFormat = "h:mm a"
        alarmTimeDisplayCell.detailTextLabel?.text = dateFormatter.stringFromDate(alarmTime!)
    }
    
    /**
        Updates the contact IDs.
    
        :param: contacts The contacts IDs that were selected.
    */
    func updateContacts(contactIDs: [ABRecordID]) {
        self.contactIDs = contactIDs
        updateContactsLabel()
    }
    
    /**
        Updates the contacts detail label.
    
        The contacts detail label does not display a number if no contacts have been selected yet or if the number of contacts selected is zero. Otherwise, if at least one contact is selected, it displays the number of contacts.
    */
    func updateContactsLabel() {
        let contactsCell = tableView(tableView, cellForRowAtIndexPath: indexPaths["Contacts"]!)
        
        if contactIDs != nil && contactIDs!.count > 0 {
            contactsCell.detailTextLabel?.text = "\(contactIDs!.count)"
        }
        else {
            contactsCell.detailTextLabel?.text = " "
        }
        
        // Resizes contacts cell to fit label.
        contactsCell.detailTextLabel?.sizeToFit()
    }
    
    /**
        Updates the map items.
    
        :param: mapItems The map items that were selected.
    */
    func updateMapItems(mapItems: [MapItem]) {
        self.mapItems = mapItems
        updateLocationsLabel()
    }
    
    /**
        Updates the locations detail label.
    
        The locations detail label does not display a number if no map items have been selected yet or if the number of map items selected is zero. Otherwise, if at least one map item is selected, it displays the number of map items.
    */
    func updateLocationsLabel() {
        let locationsCell = tableView(tableView, cellForRowAtIndexPath: indexPaths["Locations"]!)
        
        if mapItems != nil && mapItems!.count > 0 {
            locationsCell.detailTextLabel?.text = "\(mapItems!.count)"
        }
        else {
            locationsCell.detailTextLabel?.text = " "
        }
        
        locationsCell.detailTextLabel?.sizeToFit()
    }
    
    // MARK: - Methods related to user permissions.
    
    /**
        Displays an alert to request access to contacts.
    
        If permission is granted, it adds the address book reference and shows the contacts view controller. If not, it displays an alert to inform the user that access to contacts is denied.
    */
    func displayContactsAccessRequest() {
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                // If given permission, get address book reference and go to next view controller.
                if granted {
                    self.addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
                    
                    self.showContactsTableViewController()
                }
                // If denied permission, display access denied message.
                else {
                    self.displayAddressBookInaccessibleAlert()
                }
            }
        }
    }
    
    /**
        Shows the contacts table view controller.
    
        This method is called when the contacts cell is selected. If the user has given access to their address book, the `ContactsTableViewController` is shown. Otherwise, this method will do nothing.
    */
    func showContactsTableViewController() {
        if addressBookAccessible() {
            // Check if app has access to address book.
            
            // Create contacts table view controller.
            let contactsTableViewController = storyboard!.instantiateViewControllerWithIdentifier("ContactsTableViewController") as! ContactsTableViewController
            
            // Load contacts.
            if contactIDs?.count > 0 {
                contactsTableViewController.loadData(contactIDs!)
            }
            
            // Show view controller.
            navigationController!.showViewController(contactsTableViewController, sender: self)
        }
    }
    
    /**
        Shows the locations view controller.
    
        This method is called when the locations cell is selected. If the user has given access to their location, the `LocationsViewController` is shown. Otherwise, this method will do nothing.
    */
    func showLocationsViewController() {
        if locationAccessible() {
            // Check if app has access to user locations.
            
            // Create locations view controller.
            let locationsViewController = storyboard!.instantiateViewControllerWithIdentifier("LocationsViewController") as! LocationsViewController
            
            // Load data.
            if mapItems?.count > 0 {
                locationsViewController.loadData(mapItems: mapItems!)
            }
            if contactIDs?.count > 0 {
                locationsViewController.loadData(contactIDs: contactIDs!)
            }
            
            // Show view controller.
            navigationController!.showViewController(locationsViewController, sender: self)
        }
    }
    
    // MARK: - Methods for selecting and deselecting cells.
    
    /**
        Performs selection at index path.
    
        :param: indexPath The selected index path.
    */
    func selectRowAtIndexPath(indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        
        switch indexPath.section {
        case sections["Name"]!:
            // Enable text field.
            nameTextField.userInteractionEnabled = true
            nameTextField.becomeFirstResponder()
        case sections["Start"]!:
            // Show date start picker.
            tableView.beginUpdates()
            if dateStartPickerCell.hidden {
                dateStartPickerCell.hidden = false
                tableView.insertRowsAtIndexPaths([indexPaths["StartPicker"]!], withRowAnimation: .None)
            }
            tableView.endUpdates()
        case sections["End"]!:
            // Show date end picker.
            tableView.beginUpdates()
            if dateEndPickerCell.hidden {
                dateEndPickerCell.hidden = false
                tableView.insertRowsAtIndexPaths([indexPaths["EndPicker"]!], withRowAnimation: .None)
            }
            tableView.endUpdates()
        case sections["Alarm"]!:
            // Show notifications disabled alert if notifications are turned off.
            if indexPath == indexPaths["AlarmToggle"] {
                if !alarmSwitch.userInteractionEnabled {
                    displayNotificationsDisabledAlert()
                }
            }
            else if indexPath == indexPaths["AlarmTimeDisplay"] {
                tableView.beginUpdates()
                if alarmTimePickerCell.hidden {
                    alarmTimePickerCell.hidden = false
                    tableView.insertRowsAtIndexPaths([indexPaths["AlarmTimePicker"]!], withRowAnimation: .None)
                }
                tableView.endUpdates()
            }
        case sections["Contacts"]!:
            // Ensure permission to access address book, then segue to contacts view.
            let authorizationStatus = ABAddressBookGetAuthorizationStatus()
            
            // If contacts access is authorized, show contacts view. Else, display request for access.
            switch authorizationStatus {
            case .Authorized:
                showContactsTableViewController()
            case .Denied, .Restricted:
                displayAddressBookInaccessibleAlert()
            case .NotDetermined:
                displayContactsAccessRequest()
            }
        case sections["Locations"]!:
            // Ensure permission to access user location, then segue to locations view.
            let authorizationStatus = CLLocationManager.authorizationStatus()
            
            // If user location access is authorized, show location view. Else, display request for access.
            switch authorizationStatus {
            case .AuthorizedWhenInUse, .AuthorizedAlways:
                showLocationsViewController()
            case .Restricted, .Denied:
                displayLocationInaccessibleAlert()
            case .NotDetermined:
                CLLocationManager().requestWhenInUseAuthorization()
            }
        default:
            break
        }
    }
    
    /**
        Performs deselection at index path.
        
        :param: indexPath The deselected index path.
    */
    func deselectRowAtIndexPath(indexPath: NSIndexPath) {
        // Perform deselection action based on the row that was deselected.
        
        switch indexPath.section {
        case sections["Name"]!:
            // If deselecting event name field, text field stops editing.
            nameTextField.userInteractionEnabled = false
            nameTextField.resignFirstResponder()
        case sections["Start"]!:
            // If deselecting date start field, hide date start picker and show labels.
            if !dateStartPickerCell.hidden {
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([indexPaths["StartPicker"]!], withRowAnimation: .None)
                dateStartPickerCell.hidden = true
                tableView.endUpdates()
            }
        case sections["End"]!:
            // If deselecting date end field, hide date end picker and show labels.
            if !dateEndPickerCell.hidden {
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([indexPaths["EndPicker"]!], withRowAnimation: .None)
                dateEndPickerCell.hidden = true
                tableView.endUpdates()
            }
        case sections["Alarm"]!:
            if selectedIndexPath == indexPaths["AlarmTimeDisplay"] {
                tableView.beginUpdates()
                alarmTimePickerCell.hidden = true
                tableView.deleteRowsAtIndexPaths([indexPaths["AlarmTimePicker"]!], withRowAnimation: .None)
                tableView.endUpdates()
            }
        default:
            break
        }
        
        // Set selected to nil.
        selectedIndexPath = nil
    }
    
    // MARK: - Methods for saving the event.
    
    /**
        Saves an event's data.
    
        :returns: The saved event.
    */
    func saveEvent() -> FullEvent {
        // Set alarm time to nil if alarm is off.
        if !alarm {
            alarmTime = nil
        }
        
        if let event = event {
            // Set event info if this is an edited event.
            event.name = name
            event.dateStart = dateStart
            event.dateEnd = dateEnd
            event.alarm = alarm
            event.alarmTime = alarmTime
        }
        else {
            // Create event if this is a new event.
            event = FullEvent(id: NSUUID().UUIDString, name: name, dateStart: dateStart, dateEnd: dateEnd, alarm: alarm, alarmTime: alarmTime)
        }
        
        // Handle notification scheduling.
        
        if alarm {
            // If the alarm is on, reschedule any notifications for this event.
            rescheduleNotifications()
        }
        else {
            // If the alarm is off but notifications were scheduled for this event, turn off all event notifications.
            descheduleNotifications()
        }
        
        addNewContacts()
        removeOldContacts()
        
        addNewLocations()
        removeOldLocations()
        
        // Save event, show error if not saved successfully.
        var error: NSError?
        if !managedContext.save(&error) {
            NSLog("Error occurred while saving: %@", error!.localizedDescription)
        }
        
        return event!
    }
    
    // MARK: - Methods related to notifications and scheduling notifications.
    
    /**
        Return a `Bool` indicating whether or not a notification has been scheduled for an event.

        :returns: `true` if a notification has been scheduled for this event; `false` otherwise.
    */
    private func notificationsScheduled() -> Bool {
        // Get all scheduled notifications.
        let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
        
        // Search scheduled notifications
        let results = scheduledNotifications.filter({
            ($0.userInfo!["id"] as! String) == self.event!.id
            })
        return !results.isEmpty
    }
    
    /**
        Returns a `Bool` indicating whether or not notification times have changed for an event.

        :returns: `true` if a notification has been scheduled and its notification time has been changed; `false` otherwise.
    */
    private func notificationTimesChanged() -> Bool {
        // Get all scheduled notifications
        let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
        
        // Find notification for event, and check if notification time changed.
        let results = scheduledNotifications.filter({
            let idMatch = ($0.userInfo!["id"] as! String) == self.event!.id
            let notificationTimeChanged = $0.fireDate!.compare(self.event!.alarmTime!) != .OrderedSame
            return idMatch && notificationTimeChanged
        })
        
        // If result was found, notification time was changed.
        return !results.isEmpty
    }
    
    /**
        Schedules the notification for an event.
    
        TODO: make sure this doesn't reschedule a notification after the event has already fired a notification (unless the new alarm time is after current time).
    */
    private func scheduleNotifications() {
        NSLog("Event scheduled for time: %@", event!.alarmTime!)
        // Create notification
        let notification = UILocalNotification()
        
        // Fill in notification info
        if let name = event!.name {
            notification.alertTitle = "\(name)"
        }
        else {
            notification.alertTitle = "Event"
        }
        notification.alertBody = dateFormatter.stringFromDateInterval(fromDate: event!.dateStart, toDate: event!.dateEnd)
        notification.alertAction = "view"
        notification.fireDate = event!.alarmTime
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["id": event!.id]
        notification.category = "LAZYCALENDAR_CATEGORY"
        
        // Schedule notification
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    /**
        Deschedules the notification for an event.
    
        This method will do nothing if no notifications are scheduled.
    */
    private func descheduleNotifications() {
        NSLog("Event descheduled for event: %@", event!.id)
        // Get all schedule notifications.
        var scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
        
        // Get notifications to remove.
        let notifications = scheduledNotifications.filter({(
            $0.userInfo!["id"] as! String) == self.event!.id
        })
        
        // Cancel notifications.
        for notification in notifications {
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
    }
    
    /**
        Reschedules the notification for an event.
    
        This method will do nothing if no notifications are scheduled.
    */
    private func rescheduleNotifications() {
        descheduleNotifications()
        scheduleNotifications()
    }
    
    // MARK: - Methods for handling contacts when saving.
    
    /**
        Adds new contacts to the event.
    */
    private func addNewContacts() {
        // Check that there are any contact IDs to add.
        if contactIDs != nil && contactIDs!.count > 0 {
            let storedContacts = event!.mutableSetValueForKey("contacts")
            
            for contactID in contactIDs! {
                let record: ABRecordRef? = ABAddressBookGetPersonWithRecordID(addressBookRef, contactID)?.takeUnretainedValue()

                let firstName = ABRecordCopyValue(record, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
                let lastName = ABRecordCopyValue(record, kABPersonLastNameProperty)?.takeRetainedValue() as? String
                
                // Check if the contact has already been stored.
                let storedContact = getStoredContact(contactID)
                
                if let storedContact = storedContact {
                    // If contact exists in storage, add contact to event.
                    storedContacts.addObject(storedContact)
                    
                    addEventRelationship(storedContact)
                }
                else {
                    // If contact doesn't exist in storage, add new contact and inverse relationship.
                    let newContact = Contact(id: contactID, firstName: firstName, lastName: lastName)
                    storedContacts.addObject(newContact)
                    
                    addEventRelationship(newContact)
                }
            }
        }
    }
    
    /**
        Removes old contacts from the event.
    
        All contacts that are not currently in `contactIDs` will be removed.
    */
    private func removeOldContacts() {
        let storedContacts = event!.mutableSetValueForKey("contacts")
        let removedContacts = NSMutableSet()
        
        // Find old contacts to remove.
        for contact in storedContacts {
            let contact = contact as! Contact
            let id = contact.id
            // Search for stored contact IDs in current contact IDs. If not found, add to set of objects to remove from storage.
            if !contains(contactIDs!, id) {
                removedContacts.addObject(contact)
                removeEventRelationship(contact)
            }
        }
        storedContacts.minusSet(removedContacts as Set<NSObject>)
    }
    
    /**
        Searches the stored contacts for a contact ID. Returns the `Contact` if it was found, or `nil` if none was found.
    
        :param: contactID The ID of the contact to search for.
        :returns: The contact if it was found in storage or `nil` if none was found.
    */
    private func getStoredContact(contactID: ABRecordID) -> Contact? {
        // Create fetch request for contact
        let fetchRequest = NSFetchRequest(entityName: "Contact")
        fetchRequest.fetchLimit = 1
        
        // Contact can be found if a stored contact ID matches the given contact ID.
        let requirements = "(id == %d)"
        let predicate = NSPredicate(format: requirements, contactID)
        fetchRequest.predicate = predicate
        
        // Execute fetch request for contact
        var error: NSError? = nil
        let storedContact = managedContext.executeFetchRequest(fetchRequest, error: &error)?.first as? Contact
        if let error = error {
            NSLog("Error occurred while fetching stored contact: %@", error.localizedDescription)
        }
        return storedContact
    }
    
    // MARK: - Method for handling locations when saving event.
    
    /**
        Adds new locations to the event.
    */
    private func addNewLocations() {
        if mapItems != nil && mapItems!.count > 0 {
            let storedLocations = event!.mutableSetValueForKey("locations")
            
            for mapItem in mapItems! {
                // See if the location has been previously stored.
                let storedLocation = getStoredLocation(mapItem.coordinate)
                
                if let storedLocation = storedLocation {
                    // If location is already stored, add stored location and inverse relationship.
                    storedLocations.addObject(storedLocation)
                    addEventRelationship(storedLocation)
                }
                else {
                    // If location is new, add new location and add inverse.
                    let newLocation = Location(mapItem: mapItem)
                    storedLocations.addObject(newLocation)
                    addEventRelationship(newLocation)
                }
            }
        }
    }
    
    /**
        Removes old points of interest from the event.
    */
    private func removeOldLocations() {
        let storedLocations = event!.mutableSetValueForKey("locations")
        
        if mapItems != nil && mapItems!.count > 0 {
            var removedLocations = NSMutableSet()
            
            // Find points of interest to remove
            for location in storedLocations {
                let location = location as! Location
                // Convert to map item for comparing with current map items
                let mapItem = MapItem(location: location)
                
                if !contains(mapItems!, mapItem) {
                    removedLocations.addObject(location)
                    removeEventRelationship(location)
                }
            }
            // Remove old locations
            storedLocations.minusSet(removedLocations as Set<NSObject>)
        }
        else {
            // Remove event from all related locations and remove all locations from event.
            for location in storedLocations {
                let location = location as! Location
                removeEventRelationship(location)
            }
        
            storedLocations.removeAllObjects()
        }
    }
    
    /**
        Searches the stored locations for a given location.
    
        Currently, stored locations are found by matching coordinates.
    
        :param: coordinate The coordinate of the location to be found.
        :returns: The `Location` object if it was found or `nil` if none was found.
    */
    private func getStoredLocation(coordinate: CLLocationCoordinate2D) -> Location? {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        // Create fetch request for a location entity
        let fetchRequest = NSFetchRequest(entityName: "Location")
        fetchRequest.fetchLimit = 1
        
        // A stored location and the map item's location are considered the same if they have the same coordinates (matching latitude and longitude).
        let requirements = "((latitude - %d) < %d AND (latitude - %d) > %d) AND ((longitude - %d) < %d AND (longitude - %d) > %d)"
        let predicate = NSPredicate(format: requirements, argumentArray: [latitude, Math.epsilon, longitude, -Math.epsilon, longitude, Math.epsilon, longitude, -Math.epsilon])
        fetchRequest.predicate = predicate
        
        // Search for location in storage.
        var error: NSError? = nil
        let storedLocation = managedContext.executeFetchRequest(fetchRequest, error: &error)?.first as? Location
        if let error = error {
            NSLog("Error occurred while fetching stored location: %@", error.localizedDescription)
        }
        return storedLocation
    }
    
    /**
        Adds the event to its relationship with another object.
    
        :param: relatedObject The object that is related to the event.
    */
    private func addEventRelationship(relatedObject: NSManagedObject) {
        // Add inverse relation
        let inverse = relatedObject.mutableSetValueForKey("events")
        inverse.addObject(event!)
    }
    
    /**
        Removes the event from its relationship with another object.
    
        First, it removes the event from its inverse. Then, it checks if the relationship still has associated events. If not, the object is no longer needed and the object is removed from persistent storage. For example, if a `Location` has no related events anymore, it will be deleted.
    
        :param: relatedObject The object that was related to the event.
    */
    private func removeEventRelationship(relatedObject: NSManagedObject) {
        let inverse = relatedObject.mutableSetValueForKey("events")
        inverse.removeObject(event!)
        
        if inverse.count == 0 {
            managedContext.deleteObject(relatedObject)
        }
    }
    
    /**
        On saving events, save event and inform observers that an event was saved.
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "SaveEventSegue" || identifier == "SaveEventEditSegue" {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: "EventNotificationReceived", object: nil)
                let event = saveEvent()
                NSNotificationCenter.defaultCenter().postNotificationName("EventSaved", object: self, userInfo: ["Event": event])
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension ChangeEventViewController: UITableViewDelegate {
    // MARK: - Methods for heights.
    
    /**
        If cell contains a date picker, cell height is height of date picker. Otherwise use default cell height.
    */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == indexPaths["StartPicker"]! ||
            indexPath == indexPaths["EndPicker"]! ||
            indexPath == indexPaths["AlarmTimePicker"]! {
                return UIPickerView().frame.height
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    // MARK: - Methods for selection and deselection.
    
    /**
        Performs actions based on selected index path.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectRowAtIndexPath(indexPath)
    }
    
    /**
        Deselect cell when a different cell is selected.
    */
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        deselectRowAtIndexPath(indexPath)
    }
}

// MARK: - UITableViewDataSource
extension ChangeEventViewController: UITableViewDataSource {
    // MARK: - Methods for sections and rows.
    
    /**
        The number of sections in the table view.
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    /**
        If the date start or end is not selected, show only the time display and not the picker. If the alarm is off, show only the alarm toggle cell.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sections["Start"] && dateStartPickerCell.hidden {
            return 1
        }
        else if section == sections["End"] && dateEndPickerCell.hidden {
            return 1
        }
        else if section == sections["Alarm"] && alarmTimePickerCell.hidden {
            if alarmDateToggleCell.hidden && alarmTimeDisplayCell.hidden {
                return 1
            }
            else {
                return 3
            }
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    /**
        Creates the cell at an index path.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)

        cell.setNeedsDisplay()
        
        return cell
    }
}

extension ChangeEventViewController: UITextFieldDelegate {
    /**
        When the return button is pressed, resign the text field to hide the keyboard.
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
}