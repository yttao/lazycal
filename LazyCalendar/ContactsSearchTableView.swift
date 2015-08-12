//
//  ContactsSearchTableView.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/12/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class ContactsSearchTableView: UITableView {

}

extension ContactsSearchTableView: ContactsSearchControllerDelegate {
    /**
        When the text field of the search controller loads, set the offset so that it matches the text field's offset and resize the contacts search table width to be the same as the text field.
    */
    func contactsSearchControllerDidLoadSearchTextField(searchTextField: UITextField) {
        println("Text field received by delegate")
        
        // Simulate cancel button size.
        let cancelButton = UIButton()
        cancelButton.titleLabel!.text = "Cancel"
        cancelButton.titleLabel!.sizeToFit()
        
        // Resize width to search text field's width minus the size of the cancel button.
        let newFrame = CGRectMake(searchTextField.frame.origin.x, frame.origin.y, searchTextField.frame.width - cancelButton.titleLabel!.frame.width - searchTextField.frame.origin.x, frame.height)
        frame = newFrame
    }
}
