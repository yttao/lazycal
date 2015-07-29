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

class ContactsTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    
    private var addressBookRef: ABAddressBookRef!
    
    private var allContacts: NSArray!
    private var selectedContacts: [ABRecordRef]!
    private var filteredContacts: [ABRecordRef]!
    
    private let reuseIdentifier = "ContactCell"
    // Search controller for address book contacts
    private var searchController: UISearchController?
    // True if searching address book is allowed.
    private var searchEnabled: Bool = true
    
    
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
        }
        
        // Get all contacts
        allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as NSArray
        
        // Create and configure search controller
        if searchEnabled {
            searchController = ({
                let controller = UISearchController(searchResultsController: nil)
                controller.searchResultsUpdater = self
                controller.dimsBackgroundDuringPresentation = false
                controller.searchBar.sizeToFit()
                controller.searchBar.delegate = self
                controller.searchBar.placeholder = "Search for New Contacts"
                controller.delegate = self
                controller.hidesNavigationBarDuringPresentation = false
                
                self.tableView.tableHeaderView = controller.searchBar
                
                return controller
            })()
        }
        // Hides search controller on view segue
        self.definesPresentationContext = true
        
    }
    
    
    /**
        Loads contacts ID data.
    
        :param: contactIDs The array of contact IDs.
    */
    func loadData(contactsIDs: [ABRecordID]) {
        selectedContacts = [ABRecordRef]()
        if ABAddressBookGetAuthorizationStatus() == .Authorized {
            addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        }
        for ID in contactsIDs {
            let person: ABRecordRef? = ABAddressBookGetPersonWithRecordID(addressBookRef, ID)?.takeUnretainedValue()
            if person != nil {
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
    func filterContentForSearchText(searchText: String) {
        let block = {
            (record: AnyObject!, bindings: [NSObject: AnyObject]!) -> Bool in
            let recordRef: ABRecordRef = record as ABRecordRef
            
            // Check if record is already recorded in selected contacts, don't show if already a selected contact.
            for (var i = 0; i < self.selectedContacts.count; i++) {
                if ABRecordGetRecordID(recordRef) == ABRecordGetRecordID(self.selectedContacts[i]) {
                    return false
                }
            }
            
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
        
        // Sort filtered contact IDs by alphabetical name
        filteredContacts.sort({
            let firstFullName = ABRecordCopyCompositeName($0).takeRetainedValue() as! String
            let secondFullName = ABRecordCopyCompositeName($1).takeRetainedValue() as! String

            return firstFullName.compare(secondFullName) == .OrderedAscending
        })
    }
    
    
    /**
        Updates search results by updating `filteredContacts`.
    */
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text)
        tableView.reloadData()
    }
    
    
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
        if searchController != nil && searchController!.active && filteredContacts.count > 0 {
            return filteredContacts.count
        }
        return selectedContacts.count
    }
    
    
    /**
        If searching, selection will append to selected contacts and deactive the search controller.
        
        The filter ensures that search results will not show contacts that are already selected, so this method cannot add duplicate contacts.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchController != nil && searchController!.active && filteredContacts.count > 0 {
            selectedContacts.append(filteredContacts[indexPath.row])
            searchController?.searchBar.text = nil
        }
        else {
            let personViewController = ABPersonViewController()
            personViewController.displayedPerson = selectedContacts[indexPath.row]
            navigationController?.showViewController(personViewController, sender: self)
        }
    }
    
    
    /**
        Configures each cell in table view with contact information.
        
        The prototype cells are subtitle types so they have a main text label and detail text label. The main text label displays the contact's first and last name. The detail text label (for now) displays the contact's main phone number.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        // Show filtered records
        if searchController != nil && searchController!.active && filteredContacts.count > 0 {
            let fullName = ABRecordCopyCompositeName(filteredContacts[indexPath.row])?.takeRetainedValue() as? String
            cell.textLabel?.text = fullName
            boldSearchTextInLabel(cell.textLabel!)
        }
        // Show selected records
        else {
            let fullName = ABRecordCopyCompositeName(selectedContacts[indexPath.row])?.takeRetainedValue() as? String
            cell.textLabel?.text = fullName
        }

        return cell
    }
    
    
    /**
        Bolds the search bar text in the result cells.
    
        :param: cell The cell to have bolded text.
        :param: text The text to show in the cell with bolded search text.
    */
    func boldSearchTextInLabel(label: UILabel) {
        let text = label.text!
        let searchText = searchController!.searchBar.text
        
        // Make range
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
        else {
            label.text = text
        }
    }
    
    
    /**
        Allow table cells to be deleted.
    
        Note: If tableView.editing = true, the left circular edit option will appear.
    */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // TODO: Don't allow editing and deleting if searching.
        return true
    }
    
    
    /**
        If delete is pressed on swipe left, delete the contact.
    */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            selectedContacts.removeAtIndex(indexPath.row)
            tableView.endUpdates()
        }
    }
    
    
    /**
        Gives option to delete event.
    */
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    
    /**
        Prevents indenting for showing circular edit button on the left when editing.
    */
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
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
        let changeEventViewController = self.navigationController?.viewControllers.first as? ChangeEventViewController
        changeEventViewController?.updateContacts(selectedContactIDs)
    }
}
