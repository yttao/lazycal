//
//  ContactTableViewCell.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/12/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    private let style = UITableViewCellStyle.Subtitle
    
    // Label with contact name
    var nameLabel: UILabel!
    // Label with contact details
    var infoLabel: UILabel!
    
    /**
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nameLabel = textLabel!
        infoLabel = detailTextLabel!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: self.style, reuseIdentifier: reuseIdentifier)
        nameLabel = textLabel!
        infoLabel = detailTextLabel!
    }
}
