//
//  ContactsSearchTableView.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/12/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import AddressBook

class ContactsSearchTableView: SearchTableView {
    private var contactsTableViewController: ContactsTableViewController! {
        get {
            return selectedResultsTableViewController as! ContactsTableViewController
        }
        set {
            selectedResultsTableViewController = newValue
        }
    }
    
    private var filteredContacts: [ABRecordRef] {
        get {
            return searchResults
        }
        set {
            searchResults = newValue
        }
    }
    
    private var allContacts: NSArray!
    
    private let addressBookRef: ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue()
    
    let cellReuseIdentifier = "ContactCell"
    
    // MARK: - Initializers
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeView(cellReuseIdentifier)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeView(cellReuseIdentifier)
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        initializeView(cellReuseIdentifier)
    }
    
    /**
        Initializes the view.
    
        :param: reuseIdentifier The cell reuse identifier.
    */
    override func initializeView(reuseIdentifier: String) {
        filteredContacts = [ABRecordRef]()
        
        // Get all contacts.
        updateAllContacts()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAllContacts", name: "applicationBecameActive", object: nil)
        
        super.initializeView(reuseIdentifier)
    }
    
    /**
        Loads initial data.
    
        :param: selectedResultsTableViewController The `ContactsTableViewController` that contains this table view.
    */
    override func loadData(#selectedResultsTableViewController: UITableViewController, searchController: SearchController) {
        self.contactsTableViewController = selectedResultsTableViewController as! ContactsTableViewController
        self.searchController = searchController
    }
    
    // MARK: - Methods for searching, handling, and updating information in the search controller.
    
    /**
        Filters the search results by the text entered in the search bar.
    
        :param: searchText The text to filter the results.
    */
    override func filterSearchResults() {
        let block = {
            (record: AnyObject!, bindings: [NSObject: AnyObject]!) -> Bool in
            let recordRef: ABRecordRef = record as ABRecordRef
            
            // Check if record is already recorded in selected contacts, don't show if already a selected contact.
            if self.contactsTableViewController.recordSelected(recordRef) {
                return false
            }
            
            // Get name, phone numbers, and emails
            let name = ABRecordCopyCompositeName(recordRef)?.takeRetainedValue() as? String
            
            let phoneNumbersMultivalue: ABMultiValueRef? = ABRecordCopyValue(recordRef, kABPersonPhoneProperty)?.takeRetainedValue()
            
            let emailsMultivalue: ABMultiValueRef? = ABRecordCopyValue(recordRef, kABPersonEmailProperty)?.takeRetainedValue()
            
            // Search name for search text
            if name?.rangeOfString(self.searchText!, options: .CaseInsensitiveSearch) != nil {
                return true
            }
            
            // Search phone numbers for search text
            for i in 0..<ABMultiValueGetCount(phoneNumbersMultivalue) {
                let phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumbersMultivalue!, i).takeRetainedValue() as! String
                if phoneNumber.rangeOfString(self.searchText!, options: .CaseInsensitiveSearch) != nil {
                    return true
                }
            }
            
            // Search emails for search text
            for i in 0..<ABMultiValueGetCount(emailsMultivalue) {
                let email = ABMultiValueCopyValueAtIndex(emailsMultivalue, i).takeRetainedValue() as! String
                if email.rangeOfString(self.searchText!, options: .CaseInsensitiveSearch) != nil {
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
            let firstName = ABRecordCopyCompositeName($0).takeRetainedValue() as! String
            let secondName = ABRecordCopyCompositeName($1).takeRetainedValue() as! String
            
            return firstName.compare(secondName) == .OrderedAscending
        })
    }
    
    // MARK: - Methods for updating information.
    
    /**
        Updates the array of all contacts. If access to the address book has changed, empty the contacts list.
    */
    func updateAllContacts() {
        // Get new contacts if any were added while app was inactive.
        if addressBookAccessible() {
            allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as NSArray
        }
        else {
            allContacts = NSArray()
        }
    }
}

// MARK: - UITableViewDelegate
extension ContactsSearchTableView: UITableViewDelegate {
    /**
        Selecting a cell will add the contact to the selected contacts and clear the search bar text.
    
        The filter ensures that search results will not show contacts that are already selected, so this method cannot add duplicate contacts.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let contact: ABRecordRef = filteredContacts[indexPath.row]
        contactsTableViewController.addContact(contact)
        searchController!.searchBar.text = nil
    }
}

// MARK: - UITableViewDataSource
extension ContactsSearchTableView: UITableViewDataSource {
    // MARK: - Methods for creating cells.
    
    /**
        Creates a `SearchTableViewCell` with the contact's name and info.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! SearchTableViewCell
        
        let contact: ABRecordRef = filteredContacts[indexPath.row]
        
        // If contact has a name, main label displays name.
        if let fullName = ABRecordCopyCompositeName(contact)?.takeRetainedValue() as? String {
            cell.mainLabel.text = fullName
            // Bold search text in name
            boldSearchTextInLabel(cell.mainLabel)
        }
        else {
            cell.mainLabel.text = " "
        }
        
        // Get phone numbers and e-mails for contact.
        let phoneNumbersMultiValue: ABMultiValueRef? = ABRecordCopyValue(contact, kABPersonPhoneProperty)?.takeRetainedValue()
        let emailsMultiValue: ABMultiValueRef? = ABRecordCopyValue(contact, kABPersonEmailProperty)?.takeRetainedValue()
        
        // If contact has an e-mail, sub label displays. e-mail.
        if ABMultiValueGetCount(emailsMultiValue) > 0 {
            let email = ABMultiValueCopyValueAtIndex(emailsMultiValue, 0)?.takeRetainedValue() as! String
            cell.subLabel.text = email
        }
        else {
            cell.subLabel.text = " "
        }
        
        // If contact has a phone number, detail label displays phone number.
        if ABMultiValueGetCount(phoneNumbersMultiValue) > 0 {
            let phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumbersMultiValue, 0)?.takeRetainedValue() as! String
            cell.detailLabel.text = phoneNumber
        }
        else {
            cell.detailLabel.text = " "
        }

        return cell
    }
}

// MARK: - UISearchResultsUpdating
extension ContactsSearchTableView: UISearchResultsUpdating {
    /**
        Updates search results by updating `filteredContacts`.
    */
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterSearchResults()
        reloadData()
    }
}
