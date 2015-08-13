//
//  ContactsSearchTableView.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/12/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import AddressBook

class ContactsSearchTableView: UITableView {
    private var contactsTableViewController: ContactsTableViewController!
    private var searchController: SearchController!
    private var filteredContacts = [ABRecordRef]()
    
    private var addressBookRef: ABAddressBookRef!
    private var allContacts: NSArray!
    
    private let reuseIdentifier = "ContactCell"

    // Maximum number of displayed search results
    private let maxSearchResults = 5
    
    // MARK: - Initializers
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Set delegate and data source.
        delegate = self
        dataSource = self
        
        if ABAddressBookGetAuthorizationStatus() == .Authorized {
            addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as NSArray
        }
        else {
            allContacts = NSArray()
        }
        
        // Register contact cell so it can be reused.
        registerClass(SearchTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // Remove insets to get rid of automatic 15 left inset spacing.
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set delegate and data source.
        delegate = self
        dataSource = self
        
        // Set address book and get all contacts
        if ABAddressBookGetAuthorizationStatus() == .Authorized {
            addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as NSArray
        }
        else {
            allContacts = NSArray()
        }
        
        // Register contact cell so it can be reused.
        registerClass(SearchTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // Remove insets to get rid of automatic 15 left inset spacing.
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        // Set delegate and data source.
        delegate = self
        dataSource = self
        
        // Set address book and get all contacts.
        if ABAddressBookGetAuthorizationStatus() == .Authorized {
            addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as NSArray
        }
        else {
            allContacts = NSArray()
        }
        
        // Register contact cell so it can be reused.
        registerClass(SearchTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // Remove insets to get rid of automatic 15 left inset spacing.
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
    }
    
    /**
        Loads initial data.
    
        :param: contactsTableViewController The `ContactsTableViewController` that contains this table view.
    */
    func loadData(#contactsTableViewController: ContactsTableViewController, searchController: SearchController) {
        self.contactsTableViewController = contactsTableViewController
        self.searchController = searchController
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
            if self.contactsTableViewController.recordSelected(recordRef) {
                return false
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
            for i in 0..<ABMultiValueGetCount(phoneNumbersMultivalue!) {
                let phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumbersMultivalue!, i).takeRetainedValue() as! String
                if phoneNumber.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                }
            }
            
            // Search emails for search text
            for i in 0..<ABMultiValueGetCount(emailsMultivalue) {
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
        Updates the table view height. The table view height is calculated to equal the height of all the cells.
    */
    func updateTableViewHeight() {
        var newHeight: CGFloat = 0.0
        for i in 0..<tableView(self, numberOfRowsInSection: 0) {
            newHeight += tableView(self, heightForRowAtIndexPath: NSIndexPath(forRow: i, inSection: 0))
        }
        let newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, newHeight)
        frame = newFrame
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
        searchController.searchBar.text = nil
    }
}

// MARK: - UITableViewDataSource
extension ContactsSearchTableView: UITableViewDataSource {
    /**
        There is one section in the table view.
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
        The number of search results equals the number of contacts found or the maximum number of search results allowed.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredContacts.count <= maxSearchResults {
            return filteredContacts.count
        }
        return maxSearchResults
    }
    
    /**
        The height of a cell is equal to 2/3 the height of a standard `UITableViewCell`.
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewCell().frame.height * SearchTableView.sizingScaleFactor
    }
    
    /**
        Creates a `SearchTableViewCell` with the contact's name and info.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        filterContacts(searchController.searchBar.text)
        updateTableViewHeight()
        reloadData()
    }
}

// MARK: - ContactsSearchControllerDelegate
extension ContactsSearchTableView: SearchControllerDelegate {
    /**
        When the text field of the search controller loads, set the offset so that it matches the text field's offset and resize the contacts search table width to be the same as the text field.
    */
    func searchControllerDidLoadSearchTextField(searchTextField: UITextField) {
        // Simulate cancel button size.
        let cancelButton = UIButton()
        cancelButton.titleLabel!.text = "Cancel"
        cancelButton.titleLabel!.sizeToFit()
        
        // Resize width to search text field's width minus the size of the cancel button.
        let newFrame = CGRectMake(searchTextField.frame.origin.x, frame.origin.y, searchTextField.frame.width - cancelButton.titleLabel!.frame.width - searchTextField.frame.origin.x, frame.height)
        frame = newFrame
    }
}
