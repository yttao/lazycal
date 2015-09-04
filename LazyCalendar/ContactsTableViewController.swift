//
//  ContactsTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/22/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import CoreData

class ContactsTableViewController: UITableViewController {
    var delegate: ContactsTableViewControllerDelegate?
    
    private let addressBookRef: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    // True if searching for new contacts is allowed.
    var editingEnabled = true
    // Cell reuse identifier
    private let reuseIdentifier = "ContactCell"
    // True if displaying contact addresses.
    var addressMode = false
    
    var event: LZEvent!
    // Array of all contacts selected for the event that have an address.
    /*var addressContacts: [LZContact] {
        var contactsWithAddresses = [LZContact]()
        for contact in event.storedContacts {
            let contact = contact as! LZContact
            let record: ABRecordRef = ABAddressBookGetPersonWithRecordID(addressBookRef, contact.id).takeUnretainedValue()
            if ContactsTableViewController.getAddressDictionary(record) != nil {
                contactsWithAddresses.append(contact)
            }
        }
        return contactsWithAddresses
    }*/
    // Array of all contacts that have been selected for address mode; set in `loadData(event:selectedContacts:)`.
    var selectedContacts: [LZContact]?
    
    // MARK: - Methods for initializing table view controller.
    
    /**
        On initialization, add self as observer for event notifications and application activation.
    */
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        // Observer for when notification pops up
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showEventNotification:", name: "EventNotificationReceived", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkAddressBookAccessibility", name: "applicationBecameActive", object: nil)
    }
    
    /**
        Set delegates and data sources, create the search controller and remove footer.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.registerClass(TwoDetailTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.bounces = false
        tableView.alwaysBounceVertical = false
        
        // Create and configure search controller
        if editingEnabled {
            initializeSearchController()
        }
        
        // Allow several contacts to be selected for address mode.
        if addressMode {
            tableView.allowsMultipleSelection = true
        }
        
        // If some contacts were previously selected for address mode, select them.
        if let selectedContacts = selectedContacts {
            // Select at correct indices.
            for contact in selectedContacts {
                let contactsArray = event.storedContacts.array as! [LZContact]
                let index = find(contactsArray, contact)!
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                self.tableView(tableView, didSelectRowAtIndexPath: indexPath)
            }
        }
    }
    
    /**
        Initializes the search controller and the search table view.
    */
    func initializeSearchController() {
        // Create search controller.
        let searchController: SearchController = {
            let controller = SearchController(searchResultsController: nil)
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.searchBarStyle = .Default
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Search for Contacts"
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        }()
        
        // Set up the search table view.
        
        // Offset the search table view so that it is below the search bar.
        let offset = CGRectOffset(searchController.searchBar.frame, 0, searchController.searchBar.frame.height)
        let frame = CGRectMake(offset.origin.x, offset.origin.y, tableView.frame.width, 0)
        let searchTableView = ContactsSearchTableView(frame: frame, style: .Plain)
        searchTableView.loadData(selectedResultsTableViewController: self, searchController: searchController)
        
        // Set search table view as delegate.
        searchController.searchControllerDelegate = searchTableView
        searchController.searchResultsUpdater = searchTableView
        
        // Overlay search table view on top of selected contacts table view.
        view.insertSubview(searchTableView, aboveSubview: tableView)
        view.didAddSubview(searchTableView)
        
        // Hides search controller on segue.
        definesPresentationContext = true
    }
    
    func loadData(#event: LZEvent, selectedContacts: [LZContact]? = nil) {
        self.event = event
        
        self.selectedContacts = selectedContacts
    }
    
    // MARK: - Methods for accessing and handling records.
    
    /**
        Returns a `Bool` indicating if a contact exists in the currently selected contacts.
    
        :param: recordRef The `ABRecordRef` of the contact to search for in selected contacts.
        :returns: `true` if the record ID is in the currently selected contacts; `false` otherwise.
    */
    func recordSelected(recordRef: ABRecordRef) -> Bool {
        // Filter by ABRecordIDs. If no records are found (recordMatch is empty), return false. Otherwise, return true.
        let contactsArray = event.storedContacts.array as! [LZContact]
        let recordMatch = contactsArray.filter({
            $0.id == ABRecordGetRecordID(recordRef)
        })
        
        return !recordMatch.isEmpty
    }
    
    /**
        Gets the address dictionary from an `ABRecordRef`. If the record does not have an address, this returns `nil`.
    
        :param: recordRef The record to get the address dictionary from.
        :returns: The address dictionary for the record or `nil` if the contact has no address dictionary.
    */
    static func getAddressDictionary(recordRef: ABRecordRef) -> [NSObject: AnyObject]? {
        let addressBookRef: ABAddressBook? = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        if let addressMultiValue: ABMultiValueRef = ABRecordCopyValue(recordRef, kABPersonAddressProperty)?.takeRetainedValue() {
            let addressDictionary = ABMultiValueCopyValueAtIndex(addressMultiValue, 0)?.takeRetainedValue() as? Dictionary<NSObject, AnyObject>
            return addressDictionary
        }
        return nil
    }
    
    /**
        Adds a record to the selected records.
    
        :param: recordRef The record to add.
    */
    func addContact(recordRef: ABRecordRef) {
        tableView.beginUpdates()
        // Insert new row.
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: event.storedContacts.count, inSection: 0)], withRowAnimation: .Automatic)
        
        let id = ABRecordGetRecordID(recordRef)
        
        // Add contact to event.
        if let storedContact = LZContact.getStoredContact(id) {
            event.addContact(storedContact)
        }
        else {
            let fullName = ABRecordCopyCompositeName(recordRef)?.takeRetainedValue() as? String
            let newContact = LZContact(id: id, name: fullName)
            event.addContact(newContact)
        }
        
        tableView.endUpdates()
    }
    
    /**
        Deletes a record from the selected records.
    
        :param: recordRef The record to delete.
        :param: indexPath The indexPath of the deleted record.
    */
    func deleteContact(contact: LZContact, atIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        // Delete row.
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        // Remove contact from event.
        event.removeContact(contact)
        tableView.endUpdates()
    }
    
    // MARK: - Methods for exiting view controller.
    
    /**
        On view exit, updates the change event view controller contacts.
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // If there is a delegate, inform that delegate of the contacts of interest.
        if addressMode {
            var selectedContacts = [LZContact]()
            
            // Get all selected rows.
            if let selectedIndexPaths = tableView.indexPathsForSelectedRows() as? [NSIndexPath] {

                // Add selected contacts.
                for indexPath in selectedIndexPaths {
                    let contact = event.storedContacts[indexPath.row] as! LZContact
                    selectedContacts.append(contact)
                }
            }
            // Inform delegate of updated contact IDs.
            delegate?.contactsTableViewControllerDidUpdateContacts(selectedContacts)
        }
        else {
            // Convert contacts to their IDs
            let contactsArray = event.storedContacts.array as! [LZContact]
            
            // Inform delegate of updated contact IDs.
            delegate?.contactsTableViewControllerDidUpdateContacts(contactsArray)
        }
    }
    
    // MARK: - Methods related to address book accessibility.
    
    /**
        Checks if the user location is accessible. If not, display an alert.
    */
    func checkAddressBookAccessibility() {
        if isViewLoaded() && view?.window != nil && !addressBookAccessible() {
            displayAddressBookInaccessibleAlert()
        }
    }
    
    /**
        When the address book is inaccessible, display an alert stating that the address book is inaccessible.
    
        If the user chooses the "Settings" option, they can change their settings. If the user chooses "Exit", they leave the contacts view and return to the previous view.
    */
    override func displayAddressBookInaccessibleAlert() {
        let alertController = UIAlertController(title: "Cannot Access Contacts", message: "You must give permission to access locations to use this feature.", preferredStyle: .Alert)
        // Alert action to change settings.
        let settingsAlertAction = UIAlertAction(title: "Settings", style: .Default, handler: {
            action in
            self.openSettings()
        })
        // Alert action to exit view controller.
        let exitAlertAction = UIAlertAction(title: "Exit", style: .Default, handler: {
            action in
            navigationController!.popViewControllerAnimated(true)
        })
        alertController.addAction(exitAlertAction)
        alertController.addAction(settingsAlertAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension ContactsTableViewController: UITableViewDelegate {
    // MARK: - Methods for setting up headers and footers.

    /**
        Hide footer view.
    */
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRectZero)
    }
    
    /**
        Height for footer is zero.
    */
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(Math.epsilon)
    }
    
    // MARK: - Methods for editing.
    
    /**
        Prevents indenting for showing circular edit button on the left when editing.
    */
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    /**
        Gives option to delete contact.
    */
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    // MARK: - Methods for selecting cells.
    
    /**
        If in normal mode, selecting a cell will show the contact's details. If in address mode, the cell will display a check mark to indicate that it is selected.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if addressMode {
            // If in address mode, put check mark next to selected contact.
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.accessoryType = .Checkmark
        }
        else {
            // If in normal mode, show contact details.
            let personViewController = ABPersonViewController()
            let contact = event.storedContacts[indexPath.row] as! LZContact
            let record: ABRecord = ABAddressBookGetPersonWithRecordID(addressBookRef, contact.id).takeRetainedValue()
            personViewController.displayedPerson = record
            navigationController!.showViewController(personViewController, sender: self)
        }
    }
    
    /**
        If in address mode, deselecting a cell will remove the check mark to indicate that it is deselected.
    
        TODO: fix deselection.
    */
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if addressMode {
            // If in address mode, remove check mark from deselected contact.
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.accessoryType = .None
        }
    }
}

// MARK: - UITableViewDataSource
extension ContactsTableViewController: UITableViewDataSource {
    // MARK: - Methods for counting sections and rows.
    
    /**
        There is 1 section in the contacts list.
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
        The number of rows is determined by the number of contacts.
    
        If the search controller is active, show the filtered contacts. If the search controller is inactive, show the selected contacts.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event.storedContacts.count
    }
    
    // MARK: - Methods for setting up cells.
    
    /**
        Configures each cell in table view with contact information.
    
        The prototype cells have a main and two detail labels. The main text label displays the contact's name. The sub label (for now) displays the contact's main e-mail. The detail label displays the contact's main phone number.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TwoDetailTableViewCell

        let contact = event.storedContacts[indexPath.row] as! LZContact
        let record: ABRecordRef = ABAddressBookGetPersonWithRecordID(addressBookRef, contact.id).takeUnretainedValue()
        
        // Main label displays name.
        if let name = contact.name {
            cell.mainLabel.attributedText = nil
            cell.mainLabel.text = name
        }
        else {
            cell.mainLabel.text = " "
        }
        
        if addressMode {
            cell.removeAllWidthConstraints()
            // If in address mode, sub label displays address.
            if let addressDictionary = ContactsTableViewController.getAddressDictionary(record) {
                let address = LZLocation.stringFromAddressDictionary(addressDictionary)
                cell.subLabel.text = address
            }
            else {
                cell.subLabel.text = " "
            }
        }
        else {
            // If in normal mode, sub label shows disclosure indicator.
            cell.accessoryType = .DisclosureIndicator
            
            let phoneNumbersMultiValue: ABMultiValueRef? = ABRecordCopyValue(record, kABPersonPhoneProperty)?.takeRetainedValue()
            let emailsMultiValue: ABMultiValueRef? = ABRecordCopyValue(record, kABPersonEmailProperty)?.takeRetainedValue()
            
            // Sub label shows e-mail.
            if ABMultiValueGetCount(emailsMultiValue) > 0 {
                let email = ABMultiValueCopyValueAtIndex(emailsMultiValue, 0)?.takeRetainedValue() as! String
                cell.subLabel.text = email
            }
            else {
                cell.subLabel.text = " "
            }
            
            // Detail label shows phone number.
            if ABMultiValueGetCount(phoneNumbersMultiValue) > 0 {
                let phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumbersMultiValue, 0)?.takeRetainedValue() as! String
                cell.detailLabel.text = phoneNumber
            }
            else {
                cell.detailLabel.text = " "
            }
        }
        
        return cell
    }
    
    // MARK: - Methods for editing.
    
    /**
        Allow table cells to be deleted by swiping left for a delete button if editing is enabled.
    
        Note: If `tableView.editing = true`, the left circular edit option will appear.
    */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if editingEnabled {
           return true
        }
        return false
    }
    
    /**
        If delete is pressed on swipe left, delete the contact.
    */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let contact = event.storedContacts[indexPath.row] as! LZContact
            deleteContact(contact, atIndexPath: indexPath)
        }
    }
}

protocol ContactsTableViewControllerDelegate {
    func contactsTableViewControllerDidUpdateContacts(contacts: [LZContact])
}