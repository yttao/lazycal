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
import CoreLocation

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
    
    private var addressBookRef: ABAddressBookRef?
    
    private let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    // Amount of error allowed for floating points
    private let EPSILON = pow(10.0, -10.0)
    
    // MARK: - Methods for initializing view controller.
    
    /**
        On initialization, get address book.
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Observer for when notification pops up
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showEventNotification:", name: "EventNotificationReceived", object: nil)
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
        
        // Get address book
        if ABAddressBookGetAuthorizationStatus() == .Authorized {
            addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        }
        
        // Set tableview delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add targets for updates
        addTargets()
        
        // Disable text field user interaction, needed to allow proper table view row selection
        nameTextField.userInteractionEnabled = false
        
        // If using a pre-existing event, load data from event.
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
        updateDateStart()
        updateDateEnd()
        // Enable/disable alarm switch depending on settings
        updateAlarmSwitchEnabled()
        updateAlarm()
        updateAlarmTime()
        updateContactsLabel()
        updateLocationsLabel()
    }
    
    /**
        Adds the necessary targets for actions.
    */
    private func addTargets() {
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
        if event.alarmTime != nil {
            alarmTime = event.alarmTime
        }
        else {
            alarmTime = event.dateStart
        }
        
        // Load Contacts as ABRecordIDs
        let storedContacts = event.contacts.allObjects as! [Contact]
        contactIDs = storedContacts.map({
            return $0.id
        })
        
        // Load Locations as MapItems
        let storedLocations = event.locations.allObjects as! [Location]
        mapItems = storedLocations.map({
            return MapItem(coordinate: CLLocationCoordinate2DMake($0.latitude, $0.longitude), name: $0.name, address: $0.address)
        })
    }
    
    // MARK: - Methods related to updating data.
    
    /**
        Update date start info.
    */
    func updateDateStart() {
        dateStart = dateStartPicker.date
        updateDateStartLabels()
        
        updateDateEndPicker()
        
        updateAlarm()
    }
    
    /**
        Update date start labels.
    */
    private func updateDateStartLabels() {
        let dateStartCell = tableView.cellForRowAtIndexPath(indexPaths["Start"]!)
        dateFormatter.dateFormat = "MMM dd, yyyy"
        //dateStartMainLabel.text = dateFormatter.stringFromDate(dateStartPicker.date)
        dateStartCell?.textLabel?.text = dateFormatter.stringFromDate(dateStartPicker.date)
        
        dateFormatter.dateFormat = "h:mm a"
        dateStartCell?.detailTextLabel?.text = dateFormatter.stringFromDate(dateStartPicker.date)
        //dateStartDetailsLabel.text = dateFormatter.stringFromDate(dateStartPicker.date)
    }
    
    /**
        Update date end info.
    */
    func updateDateEnd() {
        dateEnd = dateEndPicker.date
        updateDateEndLabels()
    }
    
    /**
        Update date end labels.
    */
    private func updateDateEndLabels() {
        let dateEndCell = tableView.cellForRowAtIndexPath(indexPaths["End"]!)
        dateFormatter.dateFormat = "MMM dd, yyyy"
        //dateEndMainLabel.text = dateFormatter.stringFromDate(dateEnd)
        dateEndCell?.textLabel?.text = dateFormatter.stringFromDate(dateEnd)
        
        dateFormatter.dateFormat = "h:mm a"
        //dateEndDetailsLabel.text = dateFormatter.stringFromDate(dateEnd)
        dateEndCell?.detailTextLabel?.text = dateFormatter.stringFromDate(dateEnd)
    }
    
    
    /**
        When date start picker is changed, update the minimum date to ensure the date end is not before the date start.
    
        The date end picker should not be able to choose a date before the date start, so it should have a lower limit placed on the date it can choose.
    */
    private func updateDateEndPicker() {
        let originalDate = dateEndPicker.date
        dateEndPicker.minimumDate = dateStart

        // If the old date end comes after the new date start, change the old date end to equal the new date start.
        if originalDate.compare(dateStart) == .OrderedAscending {
            dateEndPicker.date = dateStart
            updateDateEnd()
        }
        dateEndPicker.reloadInputViews()
    }
    
    /**
        Updates the contacts detail label.
    
        The contacts detail label does not display a number if no contacts have been selected yet or if the number of contacts selected is zero. Otherwise, if at least one contact is selected, it displays the number of contacts.
    */
    private func updateContactsLabel() {
        let contactsCell = tableView.cellForRowAtIndexPath(indexPaths["Contacts"]!)
        if contactIDs != nil && contactIDs!.count > 0 {
            contactsCell?.detailTextLabel?.text = "\(contactIDs!.count)"
        }
        else {
            contactsCell?.detailTextLabel?.text = nil
        }
        // Resizes contacts cell to fit label.
        contactsCell?.detailTextLabel?.sizeToFit()
        tableView.reloadRowsAtIndexPaths([indexPaths["Contacts"]!], withRowAnimation: .None)
    }
    
    /**
        Updates the locations detail label.
        
        The locations detail label does not display a number if no map items have been selected yet or if the number of map items selected is zero. Otherwise, if at least one map item is selected, it displays the number of map items.
    */
    private func updateLocationsLabel() {
        let locationsCell = tableView.cellForRowAtIndexPath(indexPaths["Locations"]!)
        if mapItems != nil && mapItems!.count > 0 {
            locationsCell?.detailTextLabel?.text = "\(mapItems!.count)"
        }
        else {
            locationsCell?.detailTextLabel?.text = nil
        }
        // Resize locations cell to fit label.
        locationsCell?.detailTextLabel?.sizeToFit()
        tableView.reloadRowsAtIndexPaths([indexPaths["Locations"]!], withRowAnimation: .None)
    }
    
    /**
    Updates whether or not the alarm switch is enabled.
    
    The alarm switch can be toggled if user notifications are allowed. Otherwise, the alarm switch cannot be toggled.
    
    TODO: also possibly do a check on if notification settings have changed from true -> false and all notifications are silenced properly.
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
            showFewerAlarmOptions()
        }
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
        Updates the alarm.
    
        Turning the alarm switch on shows more alarm options while turning it off shows fewer alarm options.
    */
    func updateAlarm() {
        alarm = alarmSwitch.on
        
        if alarmSwitch.on {
            showMoreAlarmOptions()
        }
        else {
            showFewerAlarmOptions()
            resetAlarmTime()
        }
    }
    
    /**
        Update the alarm time if the alarm is off.
    */
    func resetAlarmTime() {
        alarmTimePicker.date = dateStartPicker.date
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
        if alarmTimePickerCell.hidden {
            tableView.insertRowsAtIndexPaths([indexPaths["AlarmTimePicker"]!], withRowAnimation: .Automatic)
        }
        
        alarmDateToggleCell.hidden = false
        alarmTimeDisplayCell.hidden = false
        alarmTimePickerCell.hidden = false
        
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
        Update event name.
    */
    func updateName() {
        name = nameTextField.text
    }
    
    /**
        Update alarm time.
    */
    func updateAlarmTime() {
        alarmTime = alarmTimePicker.date
        updateAlarmTimeLabels()
    }
    
    /**
        Update alarm time display.
    */
    func updateAlarmTimeLabels() {
        let alarmTimeCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmTimeDisplay"]!)
        // Main label shows format: month day, year
        dateFormatter.dateFormat = "MMM dd, yyyy"
        //alarmTimeMainLabel.text = dateFormatter.stringFromDate(alarmTimePicker.date)
        alarmTimeCell?.textLabel?.text = dateFormatter.stringFromDate(alarmTime!)
        
        dateFormatter.dateFormat = "h:mm a"
        //alarmTimeDetailsLabel.text = dateFormatter.stringFromDate(alarmTimePicker.date)
        alarmTimeCell?.detailTextLabel?.text = dateFormatter.stringFromDate(alarmTime!)
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
        Updates the map items.
    
        :param: mapItems The map items that were selected.
    */
    func updateMapItems(mapItems: [MapItem]) {
        self.mapItems = mapItems
        updateLocationsLabel()
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
                    
                    self.showContactsViewController()
                }
                    // If denied permission, display access denied message.
                else {
                    self.displayContactsAccessDeniedAlert()
                }
            }
        }
    }
    
    /**
        Alerts the user that access to contacts is denied or restricted and requests a permissions change by going to settings.
    
        This occurs when the user is first prompted for access in `displayContactsAccessRequest` and denies access or in future attempts to press the contacts cell when permission is denied or restricted.
    */
    func displayContactsAccessDeniedAlert() {
        presentPermissionAlertController("Cannot Access Contacts", "You must give permission to access contacts to use this feature.")
    }
    
    /**
        Displays an alert indicating that notifications are disabled.
    
        This occurs when the user attempts to press the alarm switch or select the alarm cell when they have notifications disabled.
    */
    func displayNotificationsDisabledAlert() {
        presentPermissionAlertController("Notifications Disabled", "You must give permission to send notifications to use this feature.")
    }
    
    /**
        Alerts the user that access to user location is denied or restricted and requests a permissions change by going to settings.
    
        This occurs when the user attempts to press the locations cell when permission is denied or restricted.
    */
    func displayLocationAccessDeniedAlert() {
        presentPermissionAlertController("Cannot Access User Location", "You must give permission to access locations to use this feature.")
    }
    
    /**
        Presents a `UIAlertController` with a given title and message and options to change settings or dismiss the alert.
    
        This method is used to present an alert controller stating that permissions to a feature is denied and that settings must be changed in order for said feature to be used. On pressing the "Settings" option, settings will be opened. On pressing the "OK" option, the alert will be dismissed.
    */
    func presentPermissionAlertController(title: String?, _ message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let settingsAlertAction = UIAlertAction(title: "Settings", style: .Default, handler: {
            action in
            self.openSettings()
            })
        let okAlertAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(settingsAlertAction)
        alertController.addAction(okAlertAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
        Opens the settings menu.
        
        This is called when requested access for user information is denied and permissions should be changed.
    */
    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    /**
        Shows the contacts view controller.
    */
    func showContactsViewController() {
        let contactsTableViewController = storyboard!.instantiateViewControllerWithIdentifier("ContactsTableViewController") as! ContactsTableViewController
        
        // Load contacts IDs if they exist already.
        if contactIDs != nil {
            contactsTableViewController.loadData(contactIDs!)
        }
        
        navigationController!.showViewController(contactsTableViewController, sender: self)
    }
    
    /**
        Shows the location view controller.
    */
    func showLocationsViewController() {
        let locationsViewController = storyboard!.instantiateViewControllerWithIdentifier("LocationsViewController") as! LocationsViewController
        
        if mapItems != nil {
            locationsViewController.loadData(mapItems!)
        }
        
        navigationController!.showViewController(locationsViewController, sender: self)
    }
    
    /**
        Performs deselection at index path.
        
        :param: indexPath The deselected index path.
    */
    func deselectRowAtIndexPath(indexPath: NSIndexPath) {
        switch indexPath.section {
            // If deselecting event name field, text field stops being first responder and disables user interaction with it.
        case sections["Name"]!:
            nameTextField.userInteractionEnabled = false
            nameTextField.resignFirstResponder()
            // If deselecting date start field, hide date start picker and show labels
        case sections["Start"]!:
            tableView.beginUpdates()
            if !dateStartPickerCell.hidden {
                tableView.deleteRowsAtIndexPaths([indexPaths["StartPicker"]!], withRowAnimation: .None)
                dateStartPickerCell.hidden = true
            }
            tableView.endUpdates()
            // If deselecting date end field, hide date end picker and show labels
        case sections["End"]!:
            tableView.beginUpdates()
            if !dateEndPickerCell.hidden {
                tableView.deleteRowsAtIndexPaths([indexPaths["EndPicker"]!], withRowAnimation: .None)
                dateEndPickerCell.hidden = true
            }
            tableView.endUpdates()
        default:
            break
        }
        selectedIndexPath = nil
    }
    
    /**
        Saves an event's data.
    
        :returns: The saved event.
    */
    func saveEvent() -> FullEvent {
        let entity = NSEntityDescription.entityForName("FullEvent", inManagedObjectContext: managedContext)!
        
        // Create event if it is a new event being created, otherwise just overwrite old data.
        if event == nil {
            event = FullEvent(entity: entity, insertIntoManagedObjectContext: managedContext)
            // Assign unique ID if just created.
            event!.id = NSUUID().UUIDString
        }
        
        // Set event values
        event!.name = name
        event!.dateStart = dateStart!
        event!.dateEnd = dateEnd!
        event!.alarm = alarm
        if alarm {
            event!.alarmTime = alarmTime
            
            if notificationTimesChanged(event!) {
                descheduleNotifications(event!)
            }
            if !notificationsScheduled(event!) {
                scheduleNotifications(event!)
            }
        }
        else {
            event!.alarmTime = nil

            if notificationsScheduled(event!) {
                descheduleNotifications(event!)
            }
        }
        
        addNewContacts()
        removeOldContacts()
        
        addNewLocations()
        removeOldLocations()
        let count = event!.mutableSetValueForKey("locations").count
        println("Event locations: \(count)")
        
        let fetchRequest = NSFetchRequest(entityName: "Location")
        let allLocations = managedContext.executeFetchRequest(fetchRequest, error: nil) as! [Location]
        println("Total locations: \(allLocations.count)")
        
        // Save event
        var error: NSError?
        if !managedContext.save(&error) {
            NSLog("Error occurred while saving: %@", error!.localizedDescription)
        }
        
        return event!
    }
    
    // MARK: - Methods related to notifications and scheduling notifications.
    
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
        Return a `Bool` indicating whether or not a notification has been scheduled for an event.
    
        :param: event The event to be checked for existing notifications.
    
        :returns: `true` if a notification has been scheduled for this event; `false` otherwise.
    */
    private func notificationsScheduled(event: FullEvent) -> Bool {
        let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
        let results = scheduledNotifications.filter({(
            $0.userInfo!["id"] as! String) == event.id
            })
        return !results.isEmpty
    }
    
    /**
        Returns a `Bool` indicating whether or not notification times have changed for an event.
    
        :param: event The event to be checked for changed notification times.
    
        :returns: `true` if a notification has been scheduled and its notification time has been changed; `false` otherwise.
    */
    private func notificationTimesChanged(event: FullEvent) -> Bool {
        let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
        let results = scheduledNotifications.filter({
            ($0.userInfo!["id"] as! String) == event.id && event.alarmTime != nil &&
                $0.fireDate!.compare(event.alarmTime!) != .OrderedSame
        })
        return !results.isEmpty
    }
    
    /**
        Schedules the notification for an event.
    
        TODO: make sure this doesn't reschedule a notification after the event has already fired a notification (unless the new alarm time is after current time).
    
        :param: event The event to have a scheduled notification.
    */
    private func scheduleNotifications(event: FullEvent) {
        NSLog("Event scheduled for time: %@", event.alarmTime!.description)
        let notification = UILocalNotification()
        notification.alertTitle = "Event Notification"
        
        // Fill in notification info
        if event.name != nil {
            notification.alertBody = "\(event.name!)"
        }
        else {
            notification.alertBody = "Untitled event"
        }
        notification.alertAction = "view"
        notification.fireDate = event.alarmTime
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["id": event.id]
        notification.category = "LAZYCALENDAR_CATEGORY"
        
        // Schedule notification
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    /**
        Deschedules the notification for an event.
    
        :param: event The event that has notifications to deschedule.
    */
    private func descheduleNotifications(event: FullEvent) {
        NSLog("Event descheduled for event: %@", event.id)
        // Get all notifications
        var scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
        
        // Get notifications to remove
        let notifications = scheduledNotifications.filter({(
            $0.userInfo!["id"] as! String) == event.id
        })
        
        // Cancel notifications
        for notification in notifications {
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
    }
    
    // MARK: - Methods for handling contacts when saving.
    
    /**
        Adds new contacts to the event.
    
        :param: event The event to add contacts to.
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
                
                if storedContact != nil {
                    // If contact exists in storage, add contact to event.
                    let storedContact = storedContact!
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
    
        :param: event The event to remove contacts from.	
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
            }
        }
        storedContacts.minusSet(removedContacts as Set<NSObject>)
        
        for contact in removedContacts {
            // Remove old contact from stored contacts and inverse relationship.
            let contact = contact as! Contact
            storedContacts.removeObject(contact)
            removeEventRelationship(contact)
        }
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
                // Get values of interest to be stored.
                
                // See if the location has been previously stored.
                let storedLocation = getStoredLocation(mapItem.coordinate)
                
                if storedLocation != nil {
                    // If location is already stored, add stored location and add inverse.
                    let storedLocation = storedLocation!
                    storedLocations.addObject(storedLocation)
                    addEventRelationship(storedLocation)
                }
                else {
                    // If location is new, add new location and add inverse.
                    let newLocation = Location(coordinate: mapItem.coordinate, name: mapItem.name, address: mapItem.address)
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
                let mapItem = MapItem(coordinate: location.coordinate, name: location.name, address: location.address)
                
                if !contains(mapItems!, mapItem) {
                    removedLocations.addObject(location)
                }
            }
            // Remove old locations
            storedLocations.minusSet(removedLocations as Set<NSObject>)
            
            // Remove event from inverse relation.
            for location in removedLocations {
                let location = location as! Location
                removeEventRelationship(location)
            }
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
        let predicate = NSPredicate(format: requirements, argumentArray: [latitude, EPSILON, longitude, -EPSILON, longitude, EPSILON, longitude, -EPSILON])
        fetchRequest.predicate = predicate
        
        // Search for location in storage.
        var error: NSError? = nil
        let storedLocation = managedContext.executeFetchRequest(fetchRequest, error: &error)?.first as? Location
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
        Makes an address string out of the available information in the address dictionary.
    
        :param: addressDictionary A dictionary of address information.
    */
    private func stringFromAddressDictionary(addressDictionary: [NSObject: AnyObject]) -> String {
        return ABCreateStringWithAddressDictionary(addressDictionary, false).stringByReplacingOccurrencesOfString("\n", withString: " ")
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
extension ChangeEventViewController: UITableViewDelegate {
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
    
    /**
        Performs actions based on selected index path.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!

        selectedIndexPath = indexPath

        switch indexPath.section {
        // Enable text field
        case sections["Name"]!:
            nameTextField.userInteractionEnabled = true
            nameTextField.becomeFirstResponder()
        // Show date start picker
        case sections["Start"]!:
            tableView.beginUpdates()
            if dateStartPickerCell.hidden {
                dateStartPickerCell.hidden = false
                tableView.insertRowsAtIndexPaths([indexPaths["StartPicker"]!], withRowAnimation: .None)
            }
            tableView.endUpdates()
        // Show date end picker
        case sections["End"]!:
            tableView.beginUpdates()
            if dateEndPickerCell.hidden {
                dateEndPickerCell.hidden = false
                tableView.insertRowsAtIndexPaths([indexPaths["EndPicker"]!], withRowAnimation: .None)
            }
            tableView.endUpdates()
        // Show notifications disabled alert if notifications are turned off.
        case sections["Alarm"]!:
            if indexPath == indexPaths["AlarmToggle"]! {
                if !alarmSwitch.userInteractionEnabled {
                    displayNotificationsDisabledAlert()
                }
            }
        // Ensure permission to access address book, then segue to contacts view.
        case sections["Contacts"]!:
            let authorizationStatus = ABAddressBookGetAuthorizationStatus()
            
            // If contacts access is authorized, show contacts view. Else, display request for access.
            switch authorizationStatus {
            case .Authorized:
                showContactsViewController()
            case .Denied, .Restricted:
                displayContactsAccessDeniedAlert()
            case .NotDetermined:
                displayContactsAccessRequest()
            }
        // Ensure permission to access user location, then segue to locations view.
        case sections["Locations"]!:
            let authorizationStatus = CLLocationManager.authorizationStatus()
            
            // If user location access is authorized, show location view. Else, display request for access.
            switch authorizationStatus {
            case .AuthorizedWhenInUse, .AuthorizedAlways:
                showLocationsViewController()
            case CLAuthorizationStatus.Restricted, .Denied:
                displayLocationAccessDeniedAlert()
            case .NotDetermined:
                NSLog("Error: user location authorization status should already be determined.")
            }
        default:
            break
        }
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
    /**
        If the date start or end is not selected, show only the time display and not the picker. If the alarm is off, show only the alarm toggle cell.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sections["Start"]! && dateStartPickerCell.hidden {
            return 1
        }
        else if section == sections["End"]! && dateEndPickerCell.hidden {
            return 1
        }
        else if section == sections["Alarm"] && alarmDateToggleCell.hidden && alarmTimeDisplayCell.hidden && alarmTimeDisplayCell.hidden {
            return 1
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
}
