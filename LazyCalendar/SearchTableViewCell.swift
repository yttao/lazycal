//
//  SearchTableViewCell.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/12/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    // Cell style
    private let style = UITableViewCellStyle.Subtitle
    
    // Label with main info
    var mainLabel: UILabel!
    // Label with detail info
    var subLabel: UILabel!
    
    // MARK: - Initializers
    
    /**
        Required initializer.
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mainLabel = textLabel!
        subLabel = detailTextLabel!
        mainLabel.opaque = true
        subLabel.opaque = true
        mainLabel.font = UIFont(name: mainLabel.font.fontName, size: mainLabel.font.pointSize * SearchTableView.sizingScaleFactor)
        subLabel.font = UIFont(name: subLabel.font.fontName, size: subLabel.font.pointSize * SearchTableView.sizingScaleFactor)
        mainLabel.sizeToFit()
        subLabel.sizeToFit()
        opaque = true
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
    }
    
    /**
        Initialize `SearchTableViewCell` with a given style and reuse identifier.
    */
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: self.style, reuseIdentifier: reuseIdentifier)
        mainLabel = textLabel!
        subLabel = detailTextLabel!
        mainLabel.opaque = true
        subLabel.opaque = true
        mainLabel.font = UIFont(name: mainLabel.font.fontName, size: mainLabel.font.pointSize * SearchTableView.sizingScaleFactor)
        subLabel.font = UIFont(name: subLabel.font.fontName, size: subLabel.font.pointSize * SearchTableView.sizingScaleFactor)
        mainLabel.sizeToFit()
        subLabel.sizeToFit()
        opaque = true
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
    }
}
