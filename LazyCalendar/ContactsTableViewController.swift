//
//  ContactsTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/22/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import AddressBook

class ContactsTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var contacts = [ABRecordRef]()
    
    private let reuseIdentifier = "ContactCell"
    
    var addressBookRef: ABAddressBookRef?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as NSArray
        let totalContacts = ABAddressBookGetPersonCount(addressBookRef)
        for (var i = 0; i < totalContacts; i++) {
            let record: ABRecordRef = allContacts[i] as ABRecordRef
            let firstName: AnyObject = ABRecordCopyValue(record, kABPersonFirstNameProperty).takeRetainedValue()
            contacts.append(record)
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
        return contacts.count
    }

    
    /*
        @brief Configures each cell in table view with contact information.
        @discussion The prototype cells are subtitle types so they have a main text label and detail text label. The main text label displays the contact's first and last name. The detail text label (for now) displays the contact's main phone number.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UITableViewCell

        // Show name in main label, main phone number in detail label
        let firstName = ABRecordCopyValue(contacts[indexPath.row], kABPersonFirstNameProperty).takeRetainedValue() as! String
        let lastName = ABRecordCopyValue(contacts[indexPath.row], kABPersonLastNameProperty).takeRetainedValue() as! String
        let fullName = firstName + " " + lastName
        
        cell.textLabel?.text = fullName
        //cell.detailTextLabel?.text = contacts[indexPath.row]

        return cell
    }
}
