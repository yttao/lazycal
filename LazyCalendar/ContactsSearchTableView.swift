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
    private var filteredContacts = [ABRecordRef]()
    
    private let reuseIdentifier = "ContactCell"
    private var contactCell: UITableViewCell?
    
    // Maximum number of displayed search results
    private let maxSearchResults = 5
    
    // MARK: - Initializers
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Set delegate and data source.
        delegate = self
        dataSource = self
        
        // Register contact cell.
        //registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set delegate and data source.
        delegate = self
        dataSource = self
        
        
        // Register contact cell.
        //registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        // Set delegate and data source.
        delegate = self
        dataSource = self
        
        // Register contact cell.
        //registerClass(ContactTableViewCell.self, forCellReuseIdentifier: "ContactCell")
        registerClass(ContactTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

extension ContactsSearchTableView: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension ContactsSearchTableView: UITableViewDataSource {
    override func numberOfRowsInSection(section: Int) -> Int {
        return 1
    }
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
            return 1
            //return filteredContacts.count
        }
        return maxSearchResults
    }
    
    /**
        Creates a `ContactTableViewCell` with the contact's name and info.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! ContactTableViewCell
        cell.nameLabel.text = "foo"
        cell.infoLabel.text = "bar"
        return cell
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
