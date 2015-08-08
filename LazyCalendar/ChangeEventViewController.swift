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
import CoreLocation

class ChangeEventViewController: UITableViewController {
    // Event data to store
    private var name: String?
    private var dateStart: NSDate?
    private var dateEnd: NSDate?
    private var alarm: Bool?
    private var alarmTime: NSDate?
    private var contactIDs: [ABRecordID]?
    private var locations: [MKMapItem]?
    
    // Date formatter to control date appearances
    private let dateFormatter = NSDateFormatter()
    
    // Date start and end pickers to decide time interval
    @IBOutlet weak var dateStartPicker: UIDatePicker!
    @IBOutlet weak var dateEndPicker: UIDatePicker!
    
    @IBOutlet weak var dateStartPickerCell: UITableViewCell!
    @IBOutlet weak var dateEndPickerCell: UITableViewCell!
    
    // Text field for event name
    @IBOutlet weak var nameTextField: UITextField!
    
    // Labels to display event start info
    @IBOutlet weak var dateStartMainLabel: UILabel!
    @IBOutlet weak var dateStartDetailsLabel: UILabel!
    
    // Labels to display event end info
    @IBOutlet weak var dateEndMainLabel: UILabel!
    @IBOutlet weak var dateEndDetailsLabel: UILabel!
    
    // Toggles alarm option on/off
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var alarmDateSwitch: UISwitch!
    
    // Displays alarm time
    @IBOutlet weak var alarmTimeMainLabel: UILabel!
    @IBOutlet weak var alarmTimeDetailsLabel: UILabel!
    
    // Picks alarm time
    @IBOutlet weak var alarmTimePicker: UIDatePicker!
    
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
    
    // Heights of fields
    private let DEFAULT_CELL_HEIGHT = UITableViewCell().frame.height
    private let PICKER_CELL_HEIGHT = UIPickerView().frame.height
    
    private var selectedIndexPath: NSIndexPath?
    
    private var event: FullEvent?
    
    private var addressBookRef: ABAddressBookRef?
    
    // Amount of error allowed for floating points
    private let EPSILON = pow(10.0, -5.0)
    
    // MARK: - Methods for initializing view controller and data.
    
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
        * Disable the event name text field. This is done to allow proper cell selection (which does not work properly if the text field is selectable.
        * Set date start picker date to the selected date (or the first day of the month if none are selected) and the picker time to the current time (in hours and minutes). Set date end picker time to show one hour after the date start picker date and time.
        * Add event listeners that are informed when event date start picker or end picker are changed. Update the event start and end labels. Additionally, if the event start time is changed, the minimum time for the event end time is modified if the end time will come before the start time.
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
        
        // Disable text field user interaction, needed to allow proper table view row selection
        nameTextField.userInteractionEnabled = false
        
        // Add targets for updates
        nameTextField.addTarget(self, action: "updateName", forControlEvents: .EditingChanged)
        dateStartPicker.addTarget(self, action: "updateDateStart", forControlEvents: .ValueChanged)
        dateEndPicker.addTarget(self, action: "updateDateEnd", forControlEvents: .ValueChanged)
        alarmTimePicker.addTarget(self, action: "updateAlarmTime", forControlEvents: .ValueChanged)
        
        // If using a pre-existing event, load data from event.
        if (event != nil) {
            nameTextField.text = name
            dateStartPicker.date = dateStart!
            dateEndPicker.date = dateEnd!
            dateEndPicker.minimumDate = dateStart!
            alarmSwitch.on = alarm!
            alarmDateSwitch.on = false
            if alarmTime != nil {
                alarmTimePicker.date = alarmTime!
                showMoreAlarmOptions()
            }
            else {
                alarmTimePicker.date = dateStart!
            }
            
            // Format and set main date labels
            dateFormatter.dateFormat = "MMM dd, yyyy"
            if alarmTime != nil {
                alarmTimeMainLabel.text = dateFormatter.stringFromDate(alarmTime!)
            }
            else {
                alarmTimeMainLabel.text = dateFormatter.stringFromDate(dateStart!)
            }
            
            // Format and set details labels
            dateFormatter.dateFormat = "h:mm a"
            if alarmTime != nil {
                alarmTimeDetailsLabel.text = dateFormatter.stringFromDate(alarmTime!)
            }
            else {
                alarmTimeDetailsLabel.text = dateFormatter.stringFromDate(dateStart!)
            }
        }
        // If creating a new event, load initial data.
        else {
            // Set initial picker value to selected date and end picker value to 1 hour later
            dateStartPicker.date = dateStart!
            dateEndPicker.date = dateEnd!
            
            alarmSwitch.on = alarm!
            alarmDateSwitch.on = false
            
            alarmTimePicker.date = alarmTime!
        }
    }
    
    /**
    
    */
    
    /**
        On view appearance, update all information in table view.
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateDateStart()
        updateDateEnd()
        // Enable/disable alarm switch depending on settings
        updateAlarmSwitchEnabled()
        updateAlarmTime()
        updateContactsDetailsLabel()
        updateLocationsDetailsLabel()
    }
    
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
    
        :param: The event to edit.
    */
    func loadData(#event: FullEvent) {
        self.event = event
        name = event.name
        dateStart = event.dateStart
        dateEnd = event.dateEnd
        alarm = event.alarm
        alarmTime = event.alarmTime
        
        // Load contacts IDs
        let contactsSet = event.contacts
        if contactsSet.count > 0 && ABAddressBookGetAuthorizationStatus() == .Authorized {
            contactIDs = [ABRecordID]()
            for contact in contactsSet {
                let c = contact as! Contact
                contactIDs!.append(c.id)
            }  
        }
    }
    
    /**
        Update date start info.
    */
    func updateDateStart() {
        dateStart = dateStartPicker.date
        updateDateStartLabels()
        updateDateEndPicker(dateStart!)
        if !alarm! {
            resetAlarmTime()
        }
    }
    
    /**
        Update date start labels.
    */
    func updateDateStartLabels() {
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateStartMainLabel.text = dateFormatter.stringFromDate(dateStartPicker.date)
        
        dateFormatter.dateFormat = "h:mm a"
        dateStartDetailsLabel.text = dateFormatter.stringFromDate(dateStartPicker.date)
    }
    
    /**
        Update date end info.
    */
    func updateDateEnd() {
        dateEnd = dateEndPicker.date
        updateDateEndLabels(dateEnd!)
    }
    
    /**
        Update date end labels.
    */
    func updateDateEndLabels(date: NSDate) {
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateEndMainLabel.text = dateFormatter.stringFromDate(date)
        
        dateFormatter.dateFormat = "h:mm a"
        dateEndDetailsLabel.text = dateFormatter.stringFromDate(date)
    }
    
    
    /**
        When date start picker is changed, update the minimum date to ensure the date end is not before the date start.
    
        The date end picker should not be able to choose a date before the date start, so it should have a lower limit placed on the date it can choose.
    */
    func updateDateEndPicker(date: NSDate) {
        let originalDate = dateEndPicker.date
        dateEndPicker.minimumDate = date

        // If the old date end comes after the new date start, change the old date end to equal the new date start.
        if (originalDate.compare(dateStartPicker.date) == .OrderedAscending) {
            dateEndPicker.date = dateStartPicker.date
            updateDateEnd()
        }
        dateEndPicker.reloadInputViews()
    }
    
    
    /**
        Update the alarm time if the alarm is not already set.
    */
    func resetAlarmTime() {
        alarmTimePicker.date = dateStartPicker.date
        updateAlarmTime()
    }
    
    /**
        Updates the contacts detail label.
    
        The contacts detail label does not display a number if no contacts have been selected yet or if the number of contacts selected is zero. Otherwise, if at least one contact is selected, it displays the number of contacts.
    */
    func updateContactsDetailsLabel() {
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
        
        The locations detail label does not display a number if no locations have been selected yet or if the number of locations selected is zero. Otherwise, if at least one location is selected, it displays the number of locations.
    */
    func updateLocationsDetailsLabel() {
        let locationsCell = tableView.cellForRowAtIndexPath(indexPaths["Locations"]!)
        if locations != nil && locations!.count > 0 {
            locationsCell?.detailTextLabel?.text = "\(locations!.count)"
        }
        else {
            locationsCell?.detailTextLabel?.text = nil
        }
        // Resize locations cell to fit label.
        locationsCell?.detailTextLabel?.sizeToFit()
        tableView.reloadRowsAtIndexPaths([indexPaths["Locations"]!], withRowAnimation: .None)
    }
    
    /**
        Displays an alert indicating that notifications are disabled.
    */
    func displayNotificationsDisabledAlert() {
        let alertController = UIAlertController(title: "Notifications Disabled", message: "Notification settings can be changed in Settings.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let changeSettingsAlertAction = UIAlertAction(title: "Change Settings", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) in
            self.openSettings()
        })
        let okAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertController.addAction(changeSettingsAlertAction)
        alertController.addAction(okAlertAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
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
    
        This occurs when the user is first prompted for access and denies access or in future attempts to use contacts when permission is denied or restricted.
    */
    func displayContactsAccessDeniedAlert() {
        // Create alert for contacts access denial
        let contactsAccessDeniedAlert = UIAlertController(title: "Cannot Access Contacts",
            message: "You must give the app permission to access contacts to use this feature.",
            preferredStyle: .Alert)
        
        let changeSettingsAlertAction = UIAlertAction(title: "Change Settings", style: .Default, handler: { action in
            self.openSettings()
        })
        let okAlertAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        
        // Add option to open settings and allow contacts access
        contactsAccessDeniedAlert.addAction(changeSettingsAlertAction)
        contactsAccessDeniedAlert.addAction(okAlertAction)
        presentViewController(contactsAccessDeniedAlert, animated: true, completion: nil)
    }
    
    /**
        Alerts the user that access to user location is denied or restricted and requests a permissions change by going to settings.
    
        This occurs when the user is first prompt for access and denies access or in future attempts to use locations when permission is denied or restricted.
    */
    func displayLocationAccessDeniedAlert() {
        let locationAccessDeniedAlert = UIAlertController(title: "Cannot Access User Location", message: "You must give the app permission to access locations to use this feature.", preferredStyle: .Alert)
        
        let changeSettingsAlertAction = UIAlertAction(title: "Change Settings", style: .Default, handler: { action in
            self.openSettings()
        })
        let okAlertAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        locationAccessDeniedAlert.addAction(changeSettingsAlertAction)
        locationAccessDeniedAlert.addAction(okAlertAction)
        presentViewController(locationAccessDeniedAlert, animated: true, completion: nil)
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
        
        if locations != nil {
            locationsViewController.loadData(locations!)
        }
        
        navigationController!.showViewController(locationsViewController, sender: self)
    }
    
    /**
        Updates whether or not the alarm switch is enabled.
    
        The alarm switch can be toggled if user notifications are allowed. Otherwise, the alarm switch cannot be toggled.
    
        TODO: also possibly do a check on if notification settings have changed from true -> false and all notifications are silenced properly.
    */
    func updateAlarmSwitchEnabled() {
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        if settings.types == UIUserNotificationType.None {
            alarmSwitch.on = false
            alarm = false
            alarmSwitch.userInteractionEnabled = false
            showFewerAlarmOptions()
        }
        else {
            alarmSwitch.userInteractionEnabled = true
        }
    }
    
    /**
        On alarm switch toggle, show more or less options.
    */
    @IBAction func toggleAlarmOptions(sender: AnyObject) {
        if let alarmToggle = sender as? UISwitch {
            // On alarm switch press, deselect current selection
            if selectedIndexPath != nil && selectedIndexPath != indexPaths["AlarmToggle"] {
                deselectRowAtIndexPath(selectedIndexPath!)
            }
            selectedIndexPath = indexPaths["AlarmToggle"]
            
            alarm = alarmToggle.on
            if alarmToggle.on {
                showMoreAlarmOptions()
            }
            else {
                showFewerAlarmOptions()
                resetAlarmTime()
            }
        }
    }
    
    /**
        On tapping the name text field, deselect the currently selected field.
    */
    @IBAction func selectNameTextField(sender: AnyObject) {
        if selectedIndexPath != nil && selectedIndexPath != indexPaths["Name"] {
            deselectRowAtIndexPath(selectedIndexPath!)
        }
        selectedIndexPath = indexPaths["Name"]
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
        // Main label shows format: month day, year
        dateFormatter.dateFormat = "MMM dd, yyyy"
        alarmTimeMainLabel.text = dateFormatter.stringFromDate(alarmTimePicker.date)
        
        dateFormatter.dateFormat = "h:mm a"
        alarmTimeDetailsLabel.text = dateFormatter.stringFromDate(alarmTimePicker.date)
    }
    
    /**
        Updates the contact IDs.
    
        :param: contacts The contacts IDs that were selected.
    */
    func updateContacts(contactIDs: [ABRecordID]) {
        self.contactIDs = contactIDs
        updateContactsDetailsLabel()
    }
    
    func updateLocations(locations: [MKMapItem]) {
        self.locations = locations
        updateLocationsDetailsLabel()
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
                //dateStartPicker.hidden = true
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
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
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
        event!.alarm = alarm!
        if alarm! {
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
        //removeOldLocations()
        
        // Save event
        var error: NSError?
        if !managedContext.save(&error) {
            NSLog("Error occurred while saving: %@", error!.localizedDescription)
        }
        
        return event!
    }
    
    /**
        Return a `Bool` indicating whether or not a notification has been scheduled for an event.
    
        :param: event The event to be checked for existing notifications.
    
        :returns: `true` if a notification has been scheduled for this event; `false` otherwise.
    */
    func notificationsScheduled(event: FullEvent) -> Bool {
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
    func notificationTimesChanged(event: FullEvent) -> Bool {
        let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
        let results = scheduledNotifications.filter({
            ($0.userInfo!["id"] as! String) == event.id && event.alarmTime != nil &&
                $0.fireDate!.compare(event.alarmTime!) != .OrderedSame
        })
        return !results.isEmpty
    }
    
    /**
        Schedules the notification for an event.
    
        :param: event The event to have a scheduled notification.
    */
    func scheduleNotifications(event: FullEvent) {
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
    func descheduleNotifications(event: FullEvent) {
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
    func addNewContacts() {
        if contactIDs != nil {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            var eventContacts = event!.mutableSetValueForKey("contacts")
            
            for i in 0..<contactIDs!.count {
                let contactID = contactIDs![i]
                
                let record: ABRecordRef? = ABAddressBookGetPersonWithRecordID(addressBookRef, contactIDs![i])?.takeUnretainedValue()
                
                let firstName = ABRecordCopyValue(record, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
                let lastName = ABRecordCopyValue(record, kABPersonLastNameProperty)?.takeRetainedValue() as? String
                
                // Create fetch request for contacts
                let fetchRequest = NSFetchRequest(entityName: "Contact")
                fetchRequest.fetchLimit = 1
                // Create predicate for fetch request
                let requirements = "(id == %d)"
                let predicate = NSPredicate(format: requirements, contactID)
                fetchRequest.predicate = predicate
                // Execute fetch request for contacts
                var error: NSError? = nil
                let contact = managedContext.executeFetchRequest(fetchRequest, error: &error)?.first as? Contact
                
                // If no results, contact is new. Add Contact for first time.
                if contact == nil {
                    let entity = NSEntityDescription.entityForName("Contact", inManagedObjectContext: managedContext)!
                    let contact = Contact(entity: entity, insertIntoManagedObjectContext: managedContext)
                    
                    contact.id = contactID
                    contact.firstName = firstName
                    contact.lastName = lastName
                    
                    eventContacts.addObject(contact)
                    
                    var contactEvents = contact.mutableSetValueForKey("events")
                    contactEvents.addObject(event!)
                }
                // If results returned, contact already exists. Add existing contact to events related to the contact.
                else {
                    let contact = contact!
                    eventContacts.addObject(contact)
                    
                    var contactEvents = contact.mutableSetValueForKey("events")
                    contactEvents.addObject(event!)
                }
            }
        }
    }
    
    /**
        Removes old contacts from the event.
    
        All contacts that are not currently contained in `contactIDs` will be removed.
    
        :param: event The event to remove contacts from.	
    */
    func removeOldContacts() {
        var eventContacts = event!.mutableSetValueForKey("contacts")

        // Find contacts to remove.
        var removedContacts = [Contact]()
        
        for contact in eventContacts {
            let c = contact as! Contact
            let id = c.id
            // Check if the new list of contact IDs contains the old contact ID
            if !contains(contactIDs!, id) {
                removedContacts.append(c)
            }
        }
        // Remove deleted contacts, remove contact relation to event.
        for contact in removedContacts {
            eventContacts.removeObject(Contact)
            let contactEvents = contact.mutableSetValueForKey("events")
            contactEvents.removeObject(event!)
        }
    }
    
    // MARK: - Method for handling locations when saving event.
    
    /**
        Adds new locations to the event.
    */
    func addNewLocations() {
        if locations != nil {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            var eventLocations = event!.mutableSetValueForKey("locations")
            
            for i in 0..<locations!.count {
                let latitude = locations![i].placemark.coordinate.latitude
                let longitude = locations![i].placemark.coordinate.longitude
                
                /*let block = {(evaluatedObject: AnyObject!, expressions: [AnyObject]!, context: NSMutableDictionary!) -> AnyObject! in
                    let lat = evaluatedObject as! CLLocationDegrees
                    return fabs(lat - latitude) < self.EPSILON
                }*/
                let fetchRequest = NSFetchRequest(entityName: "Location")
                fetchRequest.fetchLimit = 1
                /*let expression = NSExpressionDescription()
                let latitudeKeyPath = NSExpression(forKeyPath: "latitude")
                let latitudeExpression = NSExpression(forBlock: block, arguments: [latitudeKeyPath])
                //let latitudeExpression = NSExpression(forFunction: "fabs:", arguments: [latitude, latitudeKeyPath])
                let latitudeDescription = NSExpressionDescription()
                latitudeDescription.name = "latitudeExpression"
                latitudeDescription.expression = latitudeExpression
                latitudeDescription.expressionResultType = NSAttributeType.DoubleAttributeType
                fetchRequest.propertiesToFetch = [latitudeDescription]*/
                let requirements = "((latitude - %d) BETWEEN {0, %d} AND (latitude - %d) BETWEEN {%d, 0}) AND ((longitude - %d) BETWEEN {0, %d} AND (longitude - %d) BETWEEN {%d, 0})"
                let predicate = NSPredicate(format: requirements, argumentArray: [latitude, EPSILON, longitude, -EPSILON, longitude, EPSILON, longitude, -EPSILON])

                var error: NSError? = nil
                let location = managedContext.executeFetchRequest(fetchRequest, error: &error)?.first as? Location
                
                if location == nil {
                    let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedContext)!
                    let location = Location(entity: entity, insertIntoManagedObjectContext: managedContext)
                    
                    location.latitude = latitude
                    location.longitude = longitude
                    
                    // Add relation
                    eventLocations.addObject(location)
                    
                    // Add inverse relation
                    var locationEvents = location.mutableSetValueForKey("events")
                    locationEvents.addObject(event!)
                }
                else {
                    let location = location!
                    
                    eventLocations.addObject(location)
                    
                    var locationEvents = location.mutableSetValueForKey("events")
                    locationEvents.addObject(event!)
                }
            }
        }
    }
    
    /**
        Removes old locations from the event.
    */
    func removeOldLocations() {
        var eventLocations = event!.mutableSetValueForKey("locations")
        
        if locations != nil {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            let newLocations = locations!.map({
                CLLocation(latitude: $0.placemark.coordinate.latitude, longitude: $0.placemark.coordinate.longitude)
            }) as [CLLocation]
            
            // Check for removed locations for an edited event and remove them. Also remove the edited event from removed locations.
            
            var removedLocations = [MKMapItem]()
            var removedSet = Set<Location>()
            // Find locations to remove
            for location in eventLocations {
                let loc = location as! Location
                let l = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
                
                if !contains(newLocations, l) {
                    removedSet.insert(loc)
                }
                
                /*if results.isEmpty {
                removedLocations.append(location)
                }*/
            }
            eventLocations.intersectSet(removedSet)
            
            /*for location in removedLocations {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            let coordinate = location.placemark.coordinate
            let fetchRequest = NSFetchRequest(entityName: "Location")
            fetchRequest.fetchLimit = 1
            let requirements = "(latitude == %d) && (longitude == %d)"
            let predicate = NSPredicate(format: requirements, coordinate.latitude, coordinate.longitude)
            fetchRequest.predicate = predicate
            var error: NSError? = nil
            let result = managedContext.executeFetchRequest(fetchRequest, error: &error)?.first as? Location
            
            if result != nil {
            eventLocations.removeObject(result!)
            }
            }*/
        }
        else {
            eventLocations.removeAllObjects()
        }
    }
    
    /**
        On saving events, save event and inform observers that an event was saved.
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "SaveEventSegue" || identifier == "SaveEventEditSegue" {
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
                return PICKER_CELL_HEIGHT
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
        Number of sections in table view.
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
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
