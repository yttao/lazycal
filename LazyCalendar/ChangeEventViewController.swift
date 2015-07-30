//
//  ChangeEventViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/9/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import CoreData
import AddressBook

class ChangeEventViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: ChangeEventViewControllerDelegate?
    
    // Date used for initialization info
    private var name: String?
    private var dateStart: NSDate?
    private var dateEnd: NSDate?
    private var alarm: Bool?
    private var alarmTime: NSDate?
    private var contactIDs: [ABRecordID]?
    
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
    private let sections = ["Name": 0, "Start": 1, "End": 2, "Alarm": 3, "Contacts": 4]
    
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
        "Contacts": NSIndexPath(forRow: 0, inSection: 4)]
    
    // Heights of fields
    private let DEFAULT_CELL_HEIGHT = UITableViewCell().frame.height
    private let PICKER_CELL_HEIGHT = UIPickerView().frame.height
    
    private var selectedIndexPath: NSIndexPath?
    
    private var event: FullEvent?
    
    private var addressBookRef: ABAddressBookRef?
    
    
    /**
        On initialization, get address book.
    */
    required init(coder aDecoder: NSCoder) {
        if ABAddressBookGetAuthorizationStatus() == .Authorized {
            addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        }
        
        super.init(coder: aDecoder)
    }
    
    
    /**
        Initialize information on view load.
        Provides setup information for the initial data, before the user changes anything.
        * Set the table view delegate and data source if they are not already set.
        * Disable the event name text field. This is done to allow proper cell selection (which is not possible if the text field can be clicked on within its section).
        * Set date start picker date to the selected date (or the first day of the month if none are selected) and the picker time to the current time (in hours and minutes). Set date end picker time to show one hour after the date start picker date and time.
        * Add event listeners that are informed when event date start picker or end picker are changed. Update the event start and end labels. Additionally, if the event start time is changed, the minimum time for the event end time is modified if the end time will come before the start time.
        * Format the event start and end labels. The main labels show the format: month day, year. The details labels show the format: hour:minutes period.
        * Default set the alarm switches off and the alarm time picker to the initial date start.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set tableview delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Disable text field user interaction, needed to allow proper table view row selection
        nameTextField.userInteractionEnabled = false
        
        // Add listeners for updates
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
        On view appearance, update all information in table view.
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateDateStart()
        updateDateEnd()
        updateAlarmTime()
        updateContactsDetailsLabel()
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
    
    
    /*
        @brief Update date end labels.
    */
    func updateDateEndLabels(date: NSDate) {
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateEndMainLabel.text = dateFormatter.stringFromDate(date)
        
        dateFormatter.dateFormat = "h:mm a"
        dateEndDetailsLabel.text = dateFormatter.stringFromDate(date)
    }
    
    
    /**
        When date start picker is changed, update the minimum date.
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
        Displays an alert to request access to contacts.
        
        If permission is granted, it adds the address book reference and shows the contacts view controller. If not, it displays an alert to inform the user that access to contacts is denied.
    */
    func displayContactsAccessRequest() {
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                // If given permission, get address book reference
                if granted {
                    self.addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
                    // Show next view controller
                    let contactsTableViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ContactsTableViewController") as! ContactsTableViewController
                    // Load contacts IDs if they exist already.
                    
                    if self.contactIDs != nil {
                        contactsTableViewController.loadData(self.contactIDs!)
                    }
                    
                    self.navigationController!.showViewController(
                        contactsTableViewController, sender: self)
                }
                // If denied permission, display access denied message.
                else {
                    self.displayContactsAccessDeniedMessage()
                }
            }
        }
    }
    
    /**
        Alerts the user that access to contacts is denied and offers chance to change permissions in settings.
        This occurs when the user is first prompted for access and denies access or in future attempts to use contacts when permission is denied.
    */
    func displayContactsAccessDeniedMessage() {
        // Create alert for contacts access denial
        let contactsAccessDeniedAlert = UIAlertController(title: "Cannot Access Contacts",
            message: "You must give the app permission to access contacts.",
            preferredStyle: .Alert)
        // Add option to open settings and allow contacts access
        contactsAccessDeniedAlert.addAction(UIAlertAction(title: "Change Settings",
            style: .Default,
            handler: { action in
                self.openSettings()
        }))
        // Add option to just continue without contacts access
        contactsAccessDeniedAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        // Show alert
        presentViewController(contactsAccessDeniedAlert, animated: true, completion: nil)
    }
    
    
    /**
        Opens the settings menu.
        
        This is called when contacts access is explicitly denied and the contacts view controller requires contacts access to continue.
    */
    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
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
        Show more alarm options
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
            println("Deselecting")
            tableView.beginUpdates()
            if !dateStartPickerCell.hidden {
                //dateStartPicker.hidden = true
                tableView.deleteRowsAtIndexPaths([indexPaths["StartPicker"]!], withRowAnimation: .None)
                dateStartPickerCell.hidden = true
                println(self.tableView(tableView, numberOfRowsInSection: 1))
            }
            //dateStartPickerCell.hidden = true
            tableView.endUpdates()
            // If deselecting date end field, hide date end picker and show labels
        case sections["End"]!:
            tableView.beginUpdates()
            if !dateEndPickerCell.hidden {
                //dateEndPickerCell.hidden = true
                tableView.deleteRowsAtIndexPaths([indexPaths["EndPicker"]!], withRowAnimation: .None)
                dateEndPickerCell.hidden = true
            }
            //dateEndPickerCell.hidden = true
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
        }
        // Set event values
        event!.name = name
        event!.dateStart = dateStart!
        event!.dateEnd = dateEnd!
        event!.alarm = alarm!
        if alarm! {
            event!.alarmTime = alarmTime
        }
        else {
            event!.alarmTime = nil
        }
        
        addNewContacts()
        removeOldContacts()
        
        // Save event
        var error: NSError?
        if !managedContext.save(&error) {
            NSLog("%@, %@", error!, error!.userInfo!)
        }
        
        return event!
    }
    
    /**
        Adds new contacts.
    */
    func addNewContacts() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var eventContacts = event!.mutableSetValueForKey("contacts")
        if contactIDs != nil {
            for (var i = 0; i < contactIDs!.count; i++) {
                let contactID = contactIDs![i]
                
                let record: ABRecordRef? = ABAddressBookGetPersonWithRecordID(addressBookRef, contactIDs![i])?.takeUnretainedValue()
                
                let firstName = ABRecordCopyValue(record, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
                let lastName = ABRecordCopyValue(record, kABPersonLastNameProperty)?.takeRetainedValue() as? String
                
                // Create fetch request for contacts
                let fetchRequest = NSFetchRequest(entityName: "Contact")
                // Create predicate for fetch request
                let requirements = "(id == %d)"
                let predicate = NSPredicate(format: requirements, contactID)
                fetchRequest.predicate = predicate
                // Execute fetch request for contacts
                var error: NSError? = nil
                let results = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [Contact]
                
                let contactEntity = NSEntityDescription.entityForName("Contact", inManagedObjectContext: managedContext)!
                
                // If no results, contact is new. Add Contact entity for first time.
                if results.count == 0 {
                    NSLog("New contact made")
                    let contact = Contact(entity: contactEntity, insertIntoManagedObjectContext: managedContext)
                    
                    contact.id = contactID
                    contact.firstName = firstName
                    contact.lastName = lastName
                    
                    eventContacts.addObject(contact)
                    
                    var contactEvents = contact.mutableSetValueForKey("events")
                    contactEvents.addObject(event!)
                }
                    // If results returned, contact already exists. Add existing contact to event contacts.
                else {
                    let contact = results.first!
                    
                    eventContacts.addObject(contact)
                    
                    var contactEvents = contact.mutableSetValueForKey("events")
                    contactEvents.addObject(event!)
                }
            }
        }
    }
    
    /**
        Removes old contacts.
    */
    func removeOldContacts() {
        var eventContacts = event!.mutableSetValueForKey("contacts")
        
        // Check for removed contacts for an edited event and remove them. Also removed the edited event from removed contacts.
        
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
        // Remove deleted contacts, remove contact connection to event.
        for (var i = 0; i < removedContacts.count; i++) {
            eventContacts.removeObject(removedContacts[i])
            let contactEvents = removedContacts[i].mutableSetValueForKey("events")
            contactEvents.removeObject(event!)
        }
    }
    
    /**
        Updates the contact IDs.
        :param: contacts The contacts IDs that were selected.
    */
    func updateContacts(contactIDs: [ABRecordID]) {
        self.contactIDs = contactIDs
        updateContactsDetailsLabel()
    }
    
    
    /**
        Updates the contacts detail label.
        
        The contacts detail label does not display a number if no contacts have been selected yet or if the number of contacts selected is zero. Otherwise, if at least one contact is selected, it displays the number of contacts.
    */
    func updateContactsDetailsLabel() {
        let contactCell = tableView.cellForRowAtIndexPath(indexPaths["Contacts"]!)
        if contactIDs != nil && contactIDs!.count > 0 {
            contactCell?.detailTextLabel?.text = "\(contactIDs!.count)"
        }
        else {
            contactCell?.detailTextLabel?.text = nil
        }
        // Resizes contact cell to fit data.
        contactCell?.detailTextLabel?.sizeToFit()
        tableView.reloadRowsAtIndexPaths([indexPaths["Contacts"]!], withRowAnimation: .None)
    }
    
    
    
    /**
        On saving events, saves event and informs the delegate that an event was saved.
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let identifier = segue.identifier {
            switch identifier {
            case "SaveEventSegue":
                let event = saveEvent()
                delegate?.changeEventViewControllerDidSaveEvent(event)
            case "CancelEventSegue":
                break
            case "SaveEventEditSegue":
                let event = saveEvent()
                delegate?.changeEventViewControllerDidSaveEvent(event)
            case "CancelEventEditSegue":
                break
            default:
                break
            }
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
        // Take action based on what section was chosen
        switch indexPath.section {
        case sections["Name"]!:
            nameTextField.userInteractionEnabled = true
            nameTextField.becomeFirstResponder()
        case sections["Start"]!:
            tableView.beginUpdates()
            // Recalculate height to show date start picker
            if dateStartPickerCell.hidden {
                dateStartPickerCell.hidden = false
                tableView.insertRowsAtIndexPaths([indexPaths["StartPicker"]!], withRowAnimation: .None)
            }
            //dateStartPickerCell.hidden = false
            tableView.endUpdates()
        case sections["End"]!:
            tableView.beginUpdates()
            if dateEndPickerCell.hidden {
                dateEndPickerCell.hidden = false
                tableView.insertRowsAtIndexPaths([indexPaths["EndPicker"]!], withRowAnimation: .None)
            }
            // Recalculate height to show date end picker
            //dateEndPickerCell.hidden = false
            tableView.endUpdates()
        case sections["Contacts"]!:
            // Create initial alert notification (first time permission request) for data.
            
            // Get authorization status
            let authorizationStatus = ABAddressBookGetAuthorizationStatus()
            
            switch authorizationStatus {
                // If denied, display message for permission.
            case .Denied, .Restricted:
                displayContactsAccessDeniedMessage()
                // If granted, continue to next view controller for contacts.
            case .Authorized:
                let contactsTableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContactsTableViewController") as! ContactsTableViewController
                
                // Load contacts IDs if they exist already.
                if contactIDs != nil {
                    contactsTableViewController.loadData(contactIDs!)
                }
                
                self.navigationController?.showViewController(
                    contactsTableViewController, sender: self)
                
                // If undetermined, ask for permission.
            case .NotDetermined:
                displayContactsAccessRequest()
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

/**
    Delegate protocol for ChangeEventViewController.
*/
protocol ChangeEventViewControllerDelegate {
    /**
        Informs the delegate that the `ChangeEventViewController` just saved an event.
    
        :param: event The saved event.
    */
    func changeEventViewControllerDidSaveEvent(event: FullEvent)
}
