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
    private var contactsIDs: [ABRecordID]?
    
    // Date formatter to control date appearances
    private let dateFormatter = NSDateFormatter()
    
    // Date start and end pickers to decide time interval
    private let dateStartPicker = UIDatePicker()
    private let dateEndPicker = UIDatePicker()

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
        "Start": NSIndexPath(forRow: 0, inSection: 1), "End": NSIndexPath(forRow: 0, inSection: 2),
        "AlarmToggle": NSIndexPath(forRow: 0, inSection: 3),
        "AlarmDateToggle": NSIndexPath(forRow: 1, inSection: 3),
        "AlarmTimeDisplay": NSIndexPath(forRow: 2, inSection: 3),
        "AlarmTimePicker": NSIndexPath(forRow: 3, inSection: 3),
        "Contacts": NSIndexPath(forRow: 0, inSection: 4)]
    
    // Heights of fields
    private let DEFAULT_CELL_HEIGHT = UITableViewCell().frame.height
    private let PICKER_CELL_HEIGHT = UIPickerView().frame.height
    
    private var eventNameCellHeight: CGFloat
    private var eventDateStartCellHeight: CGFloat
    private var eventDateEndCellHeight: CGFloat
    private var alarmToggleCellHeight: CGFloat
    private var alarmDateToggleCellHeight: CGFloat
    private var alarmTimeDisplayCellHeight: CGFloat
    private var alarmTimePickerCellHeight: CGFloat
    
    private var selectedIndexPath: NSIndexPath?
    
    private var event: FullEvent?
    
    private var addressBookRef: ABAddressBookRef?
    
    
    // Initialization, set default heights
    required init(coder aDecoder: NSCoder) {
        if ABAddressBookGetAuthorizationStatus() == .Authorized {
            addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        }
        
        eventNameCellHeight = DEFAULT_CELL_HEIGHT
        
        eventDateStartCellHeight = DEFAULT_CELL_HEIGHT
        eventDateEndCellHeight = DEFAULT_CELL_HEIGHT
        
        alarmToggleCellHeight = DEFAULT_CELL_HEIGHT
        alarmDateToggleCellHeight = 0
        alarmTimeDisplayCellHeight = 0
        alarmTimePickerCellHeight = 0
        
        super.init(coder: aDecoder)
    }
    
    
    /*
        @brief Initialize information on view load.
        @discussion Provides setup information for the initial data, before the user changes anything.
        1. Set the table view delegate and data source if they are not already set.
        2. Disable the event name text field. This is done to allow proper cell selection (which is not possible if the text field can be clicked on within its section).
        3. Set date start picker date to the selected date (or the first day of the month if none are selected) and the picker time to the current time (in hours and minutes). Set date end picker time to show one hour after the date start picker date and time.
        4. Add event listeners that are informed when event date start picker or end picker are changed. Update the event start and end labels. Additionally, if the event start time is changed, the minimum time for the event end time is modified if the end time will come before the start time.
        5. Format the event start and end labels. The main labels show the format: month day, year. The details labels show the format: hour:minutes period.
        6. Default set the alarm switches off and the alarm time picker to the initial date start.
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
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateDateStart()
        updateDateEnd()
        updateAlarmTime()
        updateContactsDetailsLabel()
    }
    
    
    /*
        @brief Initializes data with a start date.
    */
    func loadData(#dateStart: NSDate) {
        name = nil
        self.dateStart = dateStart
        let hour = NSTimeInterval(3600)
        dateEnd = dateStart.dateByAddingTimeInterval(hour)
        alarm = false
        alarmTime = dateStart
        contactsIDs = nil
    }
    
    
    /*
        @brief Initializes data with a pre-existing event.
    */
    func loadData(#event: FullEvent) {
        self.event = event
        name = event.name
        dateStart = event.dateStart
        dateEnd = event.dateEnd
        alarm = event.alarm
        alarmTime = event.alarmTime
        
        let contactsSet = event.mutableSetValueForKey("contacts")
        
        if contactsSet.count > 0 && ABAddressBookGetAuthorizationStatus() == .Authorized {
            // Add contact IDs
            /*contacts = [ABRecordRef]()
            for contact in contactsSet {
                let c = contact as! Contact
                let recordRef: ABRecordRef = ABAddressBookGetPersonWithRecordID(addressBookRef, c.id).takeRetainedValue() as ABRecordRef
                contacts!.append(recordRef)
            }*/
        }
    }
    
    
    /*
        @brief Update date start info.
    */
    func updateDateStart() {
        dateStart = dateStartPicker.date
        updateDateStartLabels(dateStart!)
        updateDateEndPicker(dateStart!)
        if !alarm! {
            resetAlarmTime()
        }
    }
    
    
    /*
        @brief Update date start labels.
    */
    func updateDateStartLabels(date: NSDate) {
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateStartMainLabel.text = dateFormatter.stringFromDate(dateStartPicker.date)
        
        dateFormatter.dateFormat = "h:mm a"
        dateStartDetailsLabel.text = dateFormatter.stringFromDate(dateStartPicker.date)
    }
    
    
    /*
        @brief Update date end info.
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
    
    
    /*
        @brief When date start picker is changed, update the minimum date.
        @discussion The date end picker should not be able to choose a date before the date start, so it should have a lower limit placed on the date it can choose.
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
    
    
    /*
        @brief Update the alarm time if the alarm is not already set.
    */
    func resetAlarmTime() {
        alarmTimePicker.date = dateStartPicker.date
        updateAlarmTime()
    }
    
    
    /*
        @brief Number of sections in table view.
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    

    /*
        @brief Performs actions based on selected index path.
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
            
            // Hide date start labels
            dateStartMainLabel.hidden = true
            dateStartDetailsLabel.hidden = true
            
            // Recalculate height to show date start picker
            eventDateStartCellHeight = dateStartPicker.frame.height
            
            // Show date start picker
            cell.contentView.addSubview(dateStartPicker)
            cell.contentView.didAddSubview(dateStartPicker)
            
            tableView.endUpdates()
        case sections["End"]!:
            tableView.beginUpdates()
            
            // Hide date end labels
            dateEndMainLabel.hidden = true
            dateEndDetailsLabel.hidden = true
            
            // Recalculate height to show date end picker
            eventDateEndCellHeight = dateEndPicker.frame.height
            
            // Show date end picker
            cell.contentView.addSubview(dateEndPicker)
            cell.contentView.didAddSubview(dateEndPicker)
            
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
                self.navigationController?.showViewController(contactsTableViewController, sender: self)
                
            // If undetermined, ask for permission.
            case .NotDetermined:
                displayContactsAccessRequest()
            }
        default:
            break
        }
    }
    
    
    /*
        @brief Displays an alert to request access to contacts.
        @discussion If permission is granted, it adds the address book reference and shows the contacts view controller. If not, it displays an alert to inform the user that access to contacts is denied.
    */
    func displayContactsAccessRequest() {
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                // If given permission, get address book reference
                if granted {
                    self.addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
                    // Show next view controller
                    let contactsTableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContactsTableViewController") as! ContactsTableViewController
                    // Load contacts IDs if they exist already.
                    
                    self.navigationController?.showViewController(
                        contactsTableViewController, sender: self)
                }
                // If denied permission, display access denied message.
                else {
                    self.displayContactsAccessDeniedMessage()
                }
            }
        }
    }
    
    
    /*
        @brief Alerts the user that access to contacts is denied and offers chance to change permissions in settings.
        @discussion This occurs when the user is first prompted for access and denies access or in future attempts to use contacts when permission is denied.
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
    
    
    /*
        @brief Opens the settings menu.
        @discussion This is called when contacts access is explicitly denied and the contacts view controller requires contacts access to continue.
    */
    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    
    
    /*
        @brief On alarm switch toggle, show more or less options.
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
    
    
    /*
        @brief Shows more alarm options
    */
    func showMoreAlarmOptions() {
        tableView.beginUpdates()
        
        // Set cell heights
        alarmDateToggleCellHeight = DEFAULT_CELL_HEIGHT
        alarmTimeDisplayCellHeight = DEFAULT_CELL_HEIGHT
        alarmTimePickerCellHeight = PICKER_CELL_HEIGHT
        
        // Show options
        alarmDateToggleCell!.hidden = false
        alarmTimeDisplayCell!.hidden = false
        alarmTimePickerCell!.hidden = false
        
        tableView.endUpdates()
    }
    
    
    /*
        @brief Shows fewer alarm options
    */
    func showFewerAlarmOptions() {
        tableView.beginUpdates()
        
        // Get alarm options cells
        let alarmDateToggleCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmDateToggle"]!)
        let alarmTimeDisplayCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmTimeDisplay"]!)
        let alarmTimePickerCell = tableView.cellForRowAtIndexPath(indexPaths["AlarmTimePicker"]!)
        
        // Set cell heights to 0
        alarmDateToggleCellHeight = 0
        alarmTimeDisplayCellHeight = 0
        alarmTimePickerCellHeight = 0
        
        // Hide options
        alarmDateToggleCell!.hidden = true
        alarmTimeDisplayCell!.hidden = true
        alarmTimePickerCell!.hidden = true
        
        tableView.endUpdates()
    }
    
    
    func updateName() {
        name = nameTextField.text
    }
    
    
    func updateAlarmTime() {
        alarmTime = alarmTimePicker.date
        updateAlarmTimeLabels()
    }
    
    
    /*
        @brief Update alarm time display.
    */
    func updateAlarmTimeLabels() {
        // Main label shows format: month day, year
        dateFormatter.dateFormat = "MMM dd, yyyy"
        alarmTimeMainLabel.text = dateFormatter.stringFromDate(alarmTimePicker.date)
        
        dateFormatter.dateFormat = "h:mm a"
        alarmTimeDetailsLabel.text = dateFormatter.stringFromDate(alarmTimePicker.date)
    }
    
    
    // Called on cell deselection (when a different cell is selected)
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        deselectRowAtIndexPath(indexPath)
    }
    
    
    /*
        @brief Performs deselection of the field.
    */
    func deselectRowAtIndexPath(indexPath: NSIndexPath) {
        switch indexPath.section {
            // If deselecting event name field, text field stops being first responder and disables
            // user interaction with it.
        case sections["Name"]!:
            nameTextField.userInteractionEnabled = false
            nameTextField.resignFirstResponder()
            // If deselecting date start field, hide date start picker and show labels
        case sections["Start"]!:
            tableView.beginUpdates()
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            dateStartPicker.removeFromSuperview()
            eventDateStartCellHeight = DEFAULT_CELL_HEIGHT
            
            dateStartMainLabel.hidden = false
            dateStartDetailsLabel.hidden = false
            
            tableView.endUpdates()
            // If deselecting date end field, hide date end picker and show labels
        case sections["End"]!:
            tableView.beginUpdates()
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            dateEndPicker.removeFromSuperview()
            eventDateEndCellHeight = DEFAULT_CELL_HEIGHT
            
            dateEndMainLabel.hidden = false
            dateEndDetailsLabel.hidden = false
            
            tableView.endUpdates()
        default:
            break
        }
        selectedIndexPath = nil
    }
    
    
    // Calculates height for rows
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        // Event name field has default height
        case sections["Name"]!:
            return eventNameCellHeight
        // Event date start field changes height based on if it is selected or not
        case sections["Start"]!:
            return eventDateStartCellHeight
        // Event date end field changes height based on if it is selected or not
        case sections["End"]!:
            return eventDateEndCellHeight
        case sections["Alarm"]!:
            switch indexPath.row {
            // Alarm toggle height
            case indexPaths["AlarmToggle"]!.row:
                return alarmToggleCellHeight
            // Use date toggle height
            case indexPaths["AlarmDateToggle"]!.row:
                return alarmDateToggleCellHeight
            // Alarm time display height
            case indexPaths["AlarmTimeDisplay"]!.row:
                return alarmTimeDisplayCellHeight
            // Alarm time picker height
            case indexPaths["AlarmTimePicker"]!.row:
                return alarmTimePickerCellHeight
            default:
                return DEFAULT_CELL_HEIGHT
            }
        default:
            return DEFAULT_CELL_HEIGHT
        }
    }
    
    
    /*
        @brief Saves an event's data.
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
        
        var eventContacts = event!.mutableSetValueForKey("contacts")
        
        //let record: ABRecordRef = ABAddressBookGetPersonWithRecordID(addressBookRef, contactsIDs![0]).takeUnretainedValue()
        
        if contactsIDs != nil {
            NSLog("Address Book: %@", addressBookRef!.description)
            for (var i = 0; i < contactsIDs!.count; i++) {
                let contactID = contactsIDs![i]
                
                let record: ABRecordRef? = ABAddressBookGetPersonWithRecordID(addressBookRef, contactsIDs![i])?.takeUnretainedValue()
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
                    // Check if contact has already been created before creating this new contact.
                if results.count == 0 {
                    let contact = Contact(entity: contactEntity, insertIntoManagedObjectContext: managedContext)
                    
                    contact.id = contactID
                    contact.firstName = firstName
                    contact.lastName = lastName
                    
                    eventContacts.addObject(contact)
                    
                    var contactEvents = contact.mutableSetValueForKey("events")
                    if !contactEvents.containsObject(event!) {
                        contactEvents.addObject(event!)
                    }
                }
                else {
                    let contact = results.first!
                    
                    eventContacts.addObject(contact)
                    
                    var contactEvents = contact.mutableSetValueForKey("events")
                    if !contactEvents.containsObject(event!) {
                        contactEvents.addObject(event!)
                    }
                }
                
            }
        }
        
        // Save event
        var error: NSError?
        if !managedContext.save(&error) {
            NSLog("Could not save %@, %@", error!, error!.userInfo!)
        }
        
        return event!
    }
    
    
    /*
        @brief Updates the contacts IDs
        @param contacts The contacts IDs that were selected.
    */
    func updateContacts(contactsIDs: [ABRecordID]) {
        self.contactsIDs = contactsIDs
        updateContactsDetailsLabel()
    }
    
    
    /*
        @brief Updates the contacts detail label.
        @discussion The contacts detail label does not display a number if no contacts have been selected yet or no contacts were selected. Otherwise, if at least one contact is selected, it displays the number of contacts.
    */
    func updateContactsDetailsLabel() {
        let contactCell = tableView.cellForRowAtIndexPath(indexPaths["Contacts"]!)
        if contactsIDs != nil && contactsIDs!.count > 0 {
            contactCell?.detailTextLabel?.text = "\(contactsIDs!.count)"
        }
        else {
            contactCell?.detailTextLabel?.text = nil
        }
        contactCell?.detailTextLabel?.sizeToFit()
        tableView.reloadRowsAtIndexPaths([indexPaths["Contacts"]!], withRowAnimation: .None)
    }
    
    
    
    /*
        @brief Prepares information for unwind segues.
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


/*
    @brief Delegate protocol for ChangeEventViewController.
    @discussion Informs delegates when it saves an event.
*/
protocol ChangeEventViewControllerDelegate {
    /*
        @brief Informs delegate that ChangeEventViewController saved an event.
        @param event The saved event.
    */
    func changeEventViewControllerDidSaveEvent(event: FullEvent)
}
