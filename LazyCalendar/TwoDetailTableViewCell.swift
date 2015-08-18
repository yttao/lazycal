//
//  TwoDetailTableViewCell.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/18/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class TwoDetailTableViewCell: UITableViewCell {
    // Cell style
    static let style = UITableViewCellStyle.Subtitle
    
    var mainLabel: UILabel!
    var subLabel: UILabel!
    var detailLabel: UILabel!
    
    // MARK: - Initializers
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initializeLabels()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)

        initializeLabels()
    }
    
    /**
        Initializes the table view cell with subtitle style and a reuse identifier of "Cell".
    */
    init() {
        super.init(style: .Subtitle, reuseIdentifier: "Cell")

        initializeLabels()
    }
    
    /**
        Initializes the table view cell with subtitle style and the given reuse identifier.
    
        :param: reuseIdentifier The cell reuse identifier.
    */
    init(reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        
        initializeLabels()
    }
    
    /**
        Initializes the labels.
    */
    private func initializeLabels() {
        // Set up main and sub labels.
        mainLabel = textLabel!
        subLabel = detailTextLabel!
        
        // Set up detail label.
        detailLabel = UILabel(frame: mainLabel.frame)
        detailLabel.font = mainLabel.font
        detailLabel.textColor = UIColor(red: (142.0 / 255.0), green: (142.0 / 255.0), blue: (147.0 / 255.0), alpha: 1)
        detailLabel.textAlignment = .Center
        
        // Add detail label as subview.
        contentView.addSubview(detailLabel)
        contentView.didAddSubview(detailLabel)
        
        // Add constraints to position the detail label.
        detailLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        let trailingConstraint = NSLayoutConstraint(item: detailLabel, attribute: .Trailing, relatedBy: .Equal, toItem: detailLabel.superview, attribute: .Trailing, multiplier: 1, constant: 2)
        let centerYConstraint = NSLayoutConstraint(item: detailLabel, attribute: .CenterY, relatedBy: .Equal, toItem: detailLabel.superview, attribute: .CenterY, multiplier: 1, constant: 0)
        addConstraint(trailingConstraint)
        addConstraint(centerYConstraint)
    }
}
