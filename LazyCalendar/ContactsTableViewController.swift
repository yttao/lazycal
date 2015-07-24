//
//  ContactsTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/22/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import AddressBook

class ContactsTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    
    /*private let contactProperties = [kABPersonFirstNameProperty,
        kABPersonLastNameProperty,
        kABPersonMiddleNameProperty,
        kABPersonPrefixProperty,
        kABPersonSuffixProperty,
        kABPersonNicknameProperty,
        kABPersonFirstNamePhoneticProperty,
        kABPersonLastNamePhoneticProperty,
        kABPersonMiddleNamePhoneticProperty,
        
        kABPersonOrganizationProperty,
        kABPersonJobTitleProperty,
        kABPersonDepartmentProperty,
        kABPersonEmailProperty,
        
        kABPersonAddressProperty,
        kABPersonDateProperty,
        kABPersonKindProperty,
        
        kABPersonSocialProfileProperty,
        kABPersonURLProperty]*/
    
    private var allContacts: NSArray?
    
    private var selectedContacts = [ABRecordRef]()
    
    private var filteredContacts = [ABRecordRef]()
    
    private let reuseIdentifier = "ContactCell"
    
    private var searchController: UISearchController?
    
    var addressBookRef: ABAddressBookRef!
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.delegate = self
            controller.delegate = self
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()

        if addressBookRef != nil {
            println("Address book ref exists")
        }
        
        allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as NSArray
    }
    
    
    /*
        @brief Filters the search results by the text entered in the search bar.
        @param searchText The text to filter the results.
    */
    func filterContentForSearchText(searchText: String) {
        let block = {
            (record: AnyObject!, bindings: [NSObject: AnyObject]!) -> Bool in
            let recordRef: ABRecordRef = record as ABRecordRef
            
            for (var i = 0; i < self.selectedContacts.count; i++) {
                if ABRecordGetRecordID(recordRef) == ABRecordGetRecordID(self.selectedContacts[i]) {
                    return false
                }
            }
            
            let name = ABRecordCopyCompositeName(recordRef)?.takeRetainedValue() as? String
            let phoneNumbersMultivalue: AnyObject? = ABRecordCopyValue(recordRef, kABPersonPhoneProperty)?.takeRetainedValue()
            let emailsMultivalue: AnyObject? = ABRecordCopyValue(recordRef, kABPersonEmailProperty)?.takeRetainedValue()

            if name?.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                return true
            }
            
            var phoneNumbers = [String]()
            for (var i = 0; i < ABMultiValueGetCount(phoneNumbersMultivalue!); i++) {
                let phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumbersMultivalue!, i).takeRetainedValue() as! String
                phoneNumbers.append(phoneNumber)
                if phoneNumber.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                }
            }
            
            var emails = [String]()
            for (var i = 0; i < ABMultiValueGetCount(emailsMultivalue); i++) {
                let email = ABMultiValueCopyValueAtIndex(emailsMultivalue, i).takeRetainedValue() as! String
                emails.append(email)
                if email.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                }
            }
            
            /*for (var i = 0; i < self.contactProperties.count; i++) {
                let value = ABRecordCopyValue(record as ABRecordRef, self.contactProperties[i])
                if value != nil {
                    let retainedValue = value.takeRetainedValue()
                    println("PROPERTY: \(self.contactProperties[i])")
                    println(object_getClass(retainedValue).description())
                    
                    if (object_getClass(retainedValue).description() == "__NSCFType") {
                        let multivalue = retainedValue as ABMultiValueRef
                        for (var j = 0; j < ABMultiValueGetCount(multivalue); j++) {
                            let multivalueValue = ABMultiValueCopyValueAtIndex(multivalue, j)
                            
                            if multivalueValue != nil {
                                let retainedMultivalue = multivalueValue.takeRetainedValue()
                                println(retainedMultivalue)
                            }
                        }
                    }
                    else {
                        println(retainedValue)
                    }
                }
            }*/
            return false
        }
        let predicate = NSPredicate(block: block)
        filteredContacts = allContacts!.filteredArrayUsingPredicate(predicate)
        filteredContacts.sort({
            let firstFullName = ABRecordCopyValue($0 as ABRecordRef, kABSourceNameProperty).takeRetainedValue() as! String
            let secondFullName = ABRecordCopyValue($1 as ABRecordRef, kABSourceNameProperty).takeRetainedValue() as! String
            return firstFullName.compare(secondFullName) == .OrderedAscending
        })
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text)
        tableView.reloadData()
    }
    
    
    /*
        @brief There is one section in the contacts list.
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    /*
        @brief The number of rows is determined by the number of contacts.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController != nil && searchController!.active {
            return filteredContacts.count
        }
        return selectedContacts.count
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchController != nil && searchController!.active {
            // Add selected contact if it isn't already in the selected contacts list.
            var alreadySelected = false
            for (var i = 0; i < selectedContacts.count; i++) {
                if ABRecordGetRecordID(selectedContacts[i]) == ABRecordGetRecordID(filteredContacts[indexPath.row]) {
                    alreadySelected = true
                    break
                }
            }
            if !alreadySelected {
                selectedContacts.append(filteredContacts[indexPath.row])
            }
            
            searchController!.active = false
        }
    }
    
    
    /*
        @brief Configures each cell in table view with contact information.
        @discussion The prototype cells are subtitle types so they have a main text label and detail text label. The main text label displays the contact's first and last name. The detail text label (for now) displays the contact's main phone number.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        if searchController != nil && searchController!.active {
            let fullName = ABRecordCopyCompositeName(filteredContacts[indexPath.row]).takeRetainedValue() as String
            cell.textLabel?.text = fullName
        }
        else {
            let fullName = ABRecordCopyCompositeName(selectedContacts[indexPath.row]).takeRetainedValue() as String
            
            cell.textLabel?.text = fullName
        }

        return cell
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        let changeEventViewController = self.navigationController?.viewControllers.first as! ChangeEventViewController
        changeEventViewController.updateContacts(selectedContacts)
    }
}
