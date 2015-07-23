//
//  ContactsTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/22/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import AddressBook

class ContactsTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate {
    
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
    
    var addressBookRef: ABAddressBookRef?
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as NSArray
        let totalContacts = ABAddressBookGetPersonCount(addressBookRef)
        filterContentForSearchText("j")
    }
    
    
    func filterContentForSearchText(searchText: String) {
        let block = {
            (record: AnyObject!, bindings: [NSObject: AnyObject]!) -> Bool in
            let recordRef: ABRecordRef = record as ABRecordRef
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
        for (var i = 0; i < filteredContacts.count; i++) {
            println(ABRecordCopyCompositeName(filteredContacts[i]).takeRetainedValue())
        }
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
        return selectedContacts.count
    }

    
    /*
        @brief Configures each cell in table view with contact information.
        @discussion The prototype cells are subtitle types so they have a main text label and detail text label. The main text label displays the contact's first and last name. The detail text label (for now) displays the contact's main phone number.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UITableViewCell

        // Show name in main label, main phone number in detail label
        //let fullName = ABRecordCopyCompositeName(selectedContacts[indexPath.row]).takeRetainedValue() as String
        
        //cell.textLabel?.text = fullName
        //cell.detailTextLabel?.text = contacts[indexPath.row]

        return cell
    }
}
