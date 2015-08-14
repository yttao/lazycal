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
    
    private var addressBookRef: ABAddressBookRef!
    private var allContacts: NSArray!
    
    // MARK: - Initializers
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeView("ContactCell")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeView("ContactCell")
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        initializeView("ContactCell")
    }
    
    /**
        Initializes the view.
    
        :param: reuseIdentifier The cell reuse identifier.
    */
    override func initializeView(reuseIdentifier: String) {
        filteredContacts = [ABRecordRef]()
        
        // Set address book and get all contacts.
        if addressBookAccessible() {
            addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as NSArray
        }
        else {
            allContacts = NSArray()
        }
        
        super.initializeView(reuseIdentifier)
    }
    
    /**
        Loads initial data.
    
        :param: contactsTableViewController The `ContactsTableViewController` that contains this table view.
    */
    override func loadData(#selectedResultsTableViewController: UITableViewController, searchController: SearchController) {
        self.contactsTableViewController = selectedResultsTableViewController as! ContactsTableViewController
        self.searchController = searchController
    }
    
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
            let phoneNumbersMultivalue: AnyObject? = ABRecordCopyValue(recordRef, kABPersonPhoneProperty)?.takeRetainedValue()
            let emailsMultivalue: AnyObject? = ABRecordCopyValue(recordRef, kABPersonEmailProperty)?.takeRetainedValue()
            
            // Search name for search text
            if name?.rangeOfString(self.searchText!, options: .CaseInsensitiveSearch) != nil {
                return true
            }
            
            // Search phone numbers for search text
            for i in 0..<ABMultiValueGetCount(phoneNumbersMultivalue!) {
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
            let firstFullName = ABRecordCopyCompositeName($0).takeRetainedValue() as! String
            let secondFullName = ABRecordCopyCompositeName($1).takeRetainedValue() as! String
            
            return firstFullName.compare(secondFullName) == .OrderedAscending
        })
    }
}

// MARK: - UITableViewDelegate
extension ContactsSearchTableView: UITableViewDelegate {
    /**
        Selecting a cell will add the contact to the selected contacts and clear the search bar text.
    
        The filter ensures that search results will not show contacts that are already selected, so this method cannot add duplicate contacts.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        contactsTableViewController.addRecord(filteredContacts[indexPath.row])
        searchController!.searchBar.text = nil
    }
}

// MARK: - UITableViewDataSource
extension ContactsSearchTableView: UITableViewDataSource {
    /**
        Creates a `SearchTableViewCell` with the contact's name and info.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! SearchTableViewCell
        
        let fullName = ABRecordCopyCompositeName(filteredContacts[indexPath.row])?.takeRetainedValue() as? String
        if fullName != nil {
            cell.mainLabel.text = fullName
            cell.subLabel.text = "foobar"
            // Bold search text in name
            boldSearchTextInLabel(cell.mainLabel)
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
