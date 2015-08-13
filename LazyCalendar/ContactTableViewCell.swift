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
        nameLabel.opaque = true
        println(nameLabel.font.pointSize)
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: nameLabel.font.pointSize * SearchTableView.sizingScaleFactor)
        nameLabel.sizeToFit()
        println(nameLabel.font.pointSize)
        infoLabel.opaque = true
        infoLabel.font = UIFont(name: infoLabel.font.fontName, size: infoLabel.font.pointSize * SearchTableView.sizingScaleFactor)
        infoLabel.sizeToFit()
        opaque = true
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
        backgroundColor = UIColor.whiteColor()
    }
    
    /**
        Initialize `ContactTableViewCell` with a given style and reuse identifier.
    */
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: self.style, reuseIdentifier: reuseIdentifier)
        nameLabel = textLabel!
        infoLabel = detailTextLabel!
        nameLabel.opaque = true
        infoLabel.opaque = true
        println(nameLabel.font.pointSize)
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: nameLabel.font.pointSize * SearchTableView.sizingScaleFactor)
        infoLabel.font = UIFont(name: infoLabel.font.fontName, size: infoLabel.font.pointSize * SearchTableView.sizingScaleFactor)
        nameLabel.sizeToFit()
        infoLabel.sizeToFit()
        opaque = true
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
        backgroundColor = UIColor.whiteColor()
    }
}
