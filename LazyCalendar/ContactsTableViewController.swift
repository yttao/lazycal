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
    private var addressBookRef: ABAddressBookRef!
    
    private var allContacts: NSArray!
    private var selectedContacts: [ABRecordRef]!
    private var filteredContacts = [ABRecordRef]()
    
    private var searchController: UISearchController?
    // True if searching for new contacts is allowed.
    private var searchEnabled = true
    
    private let reuseIdentifier = "ContactCell"
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        // Observer for when notification pops up
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showEventNotification:", name: "EventNotificationReceived", object: nil)
    }
    
    /**
        Set delegates and data sources, load address book, get contacts, and create the search controller.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedContacts == nil {
            selectedContacts = [ABRecordRef]()
        }
        
        // Set table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Address book must be authorized, otherwise throw exception.
        if ABAddressBookGetAuthorizationStatus() == .Authorized {
            addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as NSArray
        }
        else {
            allContacts = NSArray()
        }
        
        // Create and configure search controller
        if searchEnabled {
            initializeSearchController()
        }
        // Hides search controller on segue.
        definesPresentationContext = true
    }
    
    /**
        Initializes the search controller.
    */
    func initializeSearchController() {
        searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Search for New Contacts"
            controller.hidesNavigationBarDuringPresentation = false
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
    }
    
    /**
        Loads initial contact IDs data.
    
        :param: contactIDs The array of contact IDs.
    */
    func loadData(contactIDs: [ABRecordID]) {
        if ABAddressBookGetAuthorizationStatus() == .Authorized {
            addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        }
        
        selectedContacts = [ABRecordRef]()
        
        for ID in contactIDs {
            if let person: ABRecordRef? = ABAddressBookGetPersonWithRecordID(addressBookRef, ID)?.takeUnretainedValue() {
                selectedContacts.append(person!)
            }
        }
    }
    
    /**
        Sets search enabled. If search is enabled, new contacts can be added. If disabled, only current contacts can be viewed.
    
        :param: enabled `true` if search is enabled; `false` otherwise.
    */
    func setSearchEnabled(enabled: Bool) {
        searchEnabled = enabled
    }
    
    /**
        Filters the search results by the text entered in the search bar.

        :param: searchText The text to filter the results.
    */
    func filterContacts(searchText: String) {
        let block = {
            (record: AnyObject!, bindings: [NSObject: AnyObject]!) -> Bool in
            let recordRef: ABRecordRef = record as ABRecordRef
            
            // Check if record is already recorded in selected contacts, don't show if already a selected contact.
            let identicalRecords = self.selectedContacts.filter({
                ABRecordGetRecordID($0) == ABRecordGetRecordID(recordRef)
            })
            if !identicalRecords.isEmpty {
                return false
            }
            /*for (var i = 0; i < self.selectedContacts.count; i++) {
                if ABRecordGetRecordID(recordRef) == ABRecordGetRecordID(self.selectedContacts[i]) {
                    return false
                }
            }*/
            
            // Get name, phone numbers, and emails
            let name = ABRecordCopyCompositeName(recordRef)?.takeRetainedValue() as? String
            let phoneNumbersMultivalue: AnyObject? = ABRecordCopyValue(recordRef, kABPersonPhoneProperty)?.takeRetainedValue()
            let emailsMultivalue: AnyObject? = ABRecordCopyValue(recordRef, kABPersonEmailProperty)?.takeRetainedValue()
            
            // Search name for search text
            if name?.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                return true
            }
            
            // Search phone numbers for search text
            for (var i = 0; i < ABMultiValueGetCount(phoneNumbersMultivalue!); i++) {
                let phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumbersMultivalue!, i).takeRetainedValue() as! String
                if phoneNumber.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                }
            }
            
            // Search emails for search text
            for (var i = 0; i < ABMultiValueGetCount(emailsMultivalue); i++) {
                let email = ABMultiValueCopyValueAtIndex(emailsMultivalue, i).takeRetainedValue() as! String
                if email.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                }
            }
            return false
        }
        
        // Create predicate and filter by predicate
        let predicate = NSPredicate(block: block)
        filteredContacts = allContacts.filteredArrayUsingPredicate(predicate) as [ABRecordRef]
        
        // Sort results and reload
        sortRecords(&filteredContacts)
    }
    
    /**
        Sorts an array of ABRecordRefs alphabetically.
    */
    func sortRecords(inout records: [ABRecordRef]) {
        // Sort filtered contact IDs by alphabetical name
        records.sort({
            let firstFullName = ABRecordCopyCompositeName($0).takeRetainedValue() as! String
            let secondFullName = ABRecordCopyCompositeName($1).takeRetainedValue() as! String
            
            return firstFullName.compare(secondFullName) == .OrderedAscending
        })
    }
    
    /**
        Bolds the search bar text in the result cells.
    
        :param: cell The cell to have bolded text.
    */
    func boldSearchTextInLabel(label: UILabel) {
        let text = label.text!
        let searchText = searchController!.searchBar.text
        
        // Find range of search text
        let boldRange = text.rangeOfString(searchText, options: .CaseInsensitiveSearch)
        
        // Check if search text is in label (can be in main or details label depending on where search text was found).
        if boldRange != nil {
            let start = distance(text.startIndex, boldRange!.startIndex)
            let length = count(searchText)
            let range = NSMakeRange(start, length)
            
            // Make bold font
            let font = UIFont.boldSystemFontOfSize(label.font.pointSize)
            
            // Create attributed text
            var attributedText = NSMutableAttributedString(string: text)
            attributedText.beginEditing()
            attributedText.addAttribute(NSFontAttributeName, value: font, range: range)
            attributedText.endEditing()
            
            // Set text
            label.attributedText = attributedText
        }
        // If search text is not in label, show label with plain text.
        else {
            label.attributedText = nil
            label.text = text
        }
    }

    /**
        On view exit, updates the change event view controller contacts.
        TODO: change this to observer-subject.
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Get IDs of selected contacts
        var selectedContactIDs = [ABRecordID]()
        for contact in selectedContacts {
            selectedContactIDs.append(ABRecordGetRecordID(contact))
        }
        
        // Return selected contacts to change event view controller
        let changeEventViewController = self.navigationController?.viewControllers.first as? ChangeEventViewController
        changeEventViewController?.updateContacts(selectedContactIDs)
    }
    
    /**
        Show an alert for the event notification. The alert provides two options: "OK" and "View Event". Tap "OK" to dismiss the alert. Tap "View Event" to show event details.
    
        This is only called if this view controller is loaded and currently visible.
    
        :param: notification The notification that a local notification was received.
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
extension ContactsTableViewController: UITableViewDelegate {
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
        return UITableViewCellEditingStyle.Delete
    }
    
    /**
        If searching, selection will append to selected contacts and clear the search bar.
    
        The filter ensures that search results will not show contacts that are already selected, so this method cannot add duplicate contacts.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchController != nil && searchController!.active && searchController!.searchBar.text != "" {
            selectedContacts.append(filteredContacts[indexPath.row])
            searchController?.searchBar.text = nil
        }
        else {
            let personViewController = ABPersonViewController()
            personViewController.displayedPerson = selectedContacts[indexPath.row]
            navigationController?.showViewController(personViewController, sender: self)
        }
    }
}

// MARK: - UITableViewDataSource
extension ContactsTableViewController: UITableViewDataSource {
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
        if searchController != nil && searchController!.active && searchController!.searchBar.text != "" {
            return filteredContacts.count
        }
        return selectedContacts.count
    }
    
    /**
        Allow table cells to be deleted.
    
        Note: If tableView.editing = true, the left circular edit option will appear. If contacts are being searched, the table cannot be edited.
    */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if searchController != nil && searchController!.searchBar.text != "" {
            return false
        }
        return true
    }
    
    /**
        If delete is pressed on swipe left, delete the contact.
    */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            selectedContacts.removeAtIndex(indexPath.row)
            tableView.endUpdates()
        }
    }
    
    /**
        Configures each cell in table view with contact information.
    
        The prototype cells have a main text label and detail text label. The main text label displays the contact's first and last name. The detail text label (for now) displays the contact's main phone number.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        // Show filtered records
        if searchController != nil && searchController!.active && searchController!.searchBar.text != "" {
            let fullName = ABRecordCopyCompositeName(filteredContacts[indexPath.row])?.takeRetainedValue() as? String
            if fullName != nil {
                cell.textLabel!.text = fullName
                // Bold search text in name
                boldSearchTextInLabel(cell.textLabel!)
            }
        }
        // Show selected records
        else {
            let fullName = ABRecordCopyCompositeName(selectedContacts[indexPath.row])?.takeRetainedValue() as? String
            if fullName != nil {
                cell.textLabel!.attributedText = nil
                cell.textLabel!.text = fullName
            }
        }
        
        return cell
    }
}

// MARK: - UISearchResultsUpdating
extension ContactsTableViewController: UISearchResultsUpdating {
    /**
        Updates search results by updating `filteredContacts`.
    */
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContacts(searchController.searchBar.text)
        tableView.reloadData()
    }
}