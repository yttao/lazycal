//
//  SearchTableViewCell.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/12/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class SearchTableViewCell: TwoDetailTableViewCell {
    
    // MARK: - Initializers
    
    /**
        Required initializer.
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeLabels()
    }
    
    /**
        Initialize `SearchTableViewCell` with a given style and reuse identifier.
    */
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        
        initializeLabels()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        initializeLabels()
    }
    
    private func initializeLabels() {
        mainLabel.font = UIFont(name: mainLabel.font.fontName, size: mainLabel.font.pointSize * SearchTableView.sizingScaleFactor)
        subLabel.font = UIFont(name: subLabel.font.fontName, size: subLabel.font.pointSize * SearchTableView.sizingScaleFactor)
        detailLabel.font = UIFont(name: mainLabel.font.fontName, size: mainLabel.font.pointSize * SearchTableView.sizingScaleFactor)
        
        mainLabel.opaque = true
        subLabel.opaque = true
        detailLabel.opaque = true
        opaque = true
        
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
    }
}
