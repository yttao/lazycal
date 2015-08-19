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
    private let addressBookRef: ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue()
    // Currently selected contacts
    private var selectedContacts: [ABRecordRef]!
    // True if searching for new contacts is allowed.
    var editingEnabled = true
    // Cell reuse identifier
    private let reuseIdentifier = "ContactCell"
    // True if displaying contact addresses.
    var addressMode = false
    // Selected addresses if in address mode.
    private var selectedAddresses: [ABRecordRef]?
    
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
        
        if selectedContacts == nil {
            selectedContacts = [ABRecordRef]()
        }
        
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
    
    /**
        Loads initial contact IDs data.
    
        If the address book is accessible, the contacts will be loaded. If not, no data will be loaded.
    
        :param: contactIDs The array of contact IDs.
    */
    func loadData(contactIDs: [ABRecordID]) {
        if addressBookAccessible() {
            
            selectedContacts = [ABRecordRef]()
            
            for ID in contactIDs {
                let person: ABRecordRef? = ABAddressBookGetPersonWithRecordID(addressBookRef, ID)?.takeUnretainedValue()
                if let person: ABRecordRef = person {
                    selectedContacts.append(person)
                }
            }
        }
    }
    
    // MARK: - Methods for accessing and handling records.
    
    /**
        Returns a `Bool` indicating if a contact exists in the currently selected contacts.
    
        :param: recordRef The `ABRecordRef` of the contact to search for in selected contacts.
        :returns: `true` if the record ID is in the currently selected contacts; `false` otherwise.
    */
    func recordSelected(recordRef: ABRecordRef) -> Bool {
        // Filter by ABRecordIDs. If no records are found (recordMatch is empty), return false. Otherwise, return true.
        let recordMatch = selectedContacts.filter({
            ABRecordGetRecordID($0) == ABRecordGetRecordID(recordRef)
        })
        return !recordMatch.isEmpty
    }
    
    /**
        Adds a record to the selected records.
    
        :param: recordRef The record to add.
    */
    func addRecord(recordRef: ABRecordRef) {
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: selectedContacts.count, inSection: 0)], withRowAnimation: .Automatic)
        selectedContacts.append(recordRef)
        tableView.endUpdates()
    }
    
    /**
        Deletes a record from the selected records.
    
        :param: recordRef The record to delete.
        :param: indexPath The indexPath of the deleted record.
    */
    func deleteRecord(recordRef: ABRecordRef, atIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        selectedContacts.removeAtIndex(indexPath.row)
        tableView.endUpdates()
    }
    
    // MARK: - Methods for exiting view controller.
    
    /**
        On view exit, updates the change event view controller contacts.
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Get IDs of selected contacts
        var selectedContactIDs = [ABRecordID]()
        for contact in selectedContacts {
            selectedContactIDs.append(ABRecordGetRecordID(contact))
        }
        
        // Return selected contacts to change event view controller
        let changeEventViewController = navigationController!.viewControllers.first as? ChangeEventViewController
        changeEventViewController?.updateContacts(selectedContactIDs)
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
        let settingsAlertAction = UIAlertAction(title: "Settings", style: .Default, handler: {
            action in
            self.openSettings()
        })
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
        If searching, selection will append to selected contacts and clear the search bar.
    
        The filter ensures that search results will not show contacts that are already selected, so this method cannot add duplicate contacts.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let personViewController = ABPersonViewController()
        personViewController.displayedPerson = selectedContacts[indexPath.row]
        navigationController!.showViewController(personViewController, sender: self)
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
        return selectedContacts.count
    }
    
    // MARK: - Methods for setting up cells.
    
    /**
        Configures each cell in table view with contact information.
    
        The prototype cells have a main text label and detail text label. The main text label displays the contact's first and last name. The detail text label (for now) displays the contact's main phone number.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TwoDetailTableViewCell
        
        let contact: ABRecordRef = selectedContacts[indexPath.row]
        
        
        
        // Main label displays name.
        if let fullName = ABRecordCopyCompositeName(contact)?.takeRetainedValue() as? String {
            cell.mainLabel.attributedText = nil
            cell.mainLabel.text = fullName
        }
        
        if addressMode {
            
            // Sub label displays address.
            if let addressMultiValue: ABMultiValueRef = ABRecordCopyValue(contact, kABPersonAddressProperty)?.takeRetainedValue() {
                for i in 0..<ABMultiValueGetCount(addressMultiValue) {
                    if let addressDictionary = ABMultiValueCopyValueAtIndex(addressMultiValue, i)?.takeRetainedValue() as? NSDictionary {
                        if let addressDictionary = addressDictionary as? Dictionary<NSObject, AnyObject> {
                            let address = MapItem.stringFromAddressDictionary(addressDictionary)
                            cell.subLabel.text = address
                        }
                    }
                }
            }
        }
        else {
            cell.accessoryType = .DisclosureIndicator
            
            let phoneNumbersMultiValue: ABMultiValueRef? = ABRecordCopyValue(contact, kABPersonPhoneProperty)?.takeRetainedValue()
            let emailsMultiValue: ABMultiValueRef? = ABRecordCopyValue(contact, kABPersonEmailProperty)?.takeRetainedValue()
            
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
            let recordRef: ABRecordRef = selectedContacts[indexPath.row]
            deleteRecord(recordRef, atIndexPath: indexPath)
        }
    }
}