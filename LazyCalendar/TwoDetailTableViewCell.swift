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
    
    var labelPositionConstraints = [NSLayoutConstraint]()
    var labelSizeConstraints = [NSLayoutConstraint]()
    
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
        
        // Main label and sub label constraints are made such that they match the constraints to make the default subtitle style. The only difference is that the labels have a width constraint as well.
        
        // Add constraints to position and size the main label.
        mainLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        let mainLabelLeadingConstraint = NSLayoutConstraint(item: mainLabel, attribute: .Leading, relatedBy: .Equal, toItem: mainLabel.superview, attribute: .Leading, multiplier: 1, constant: 15)
        let mainLabelTopConstraint = NSLayoutConstraint(item: mainLabel, attribute: .Top, relatedBy: .Equal, toItem: mainLabel.superview, attribute: .Top, multiplier: 1, constant: 5)
        let mainLabelWidthConstraint = NSLayoutConstraint(item: mainLabel, attribute: .Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: mainLabel.superview, attribute: .Width, multiplier: 0.5, constant: 0)
        labelPositionConstraints.extend([mainLabelLeadingConstraint, mainLabelTopConstraint])
        labelSizeConstraints.append(mainLabelWidthConstraint)
        
        // Add constraints to position and size the sub label.
        subLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        let subLabelLeadingConstraint = NSLayoutConstraint(item: subLabel, attribute: .Leading, relatedBy: .Equal, toItem: mainLabel, attribute: .Leading, multiplier: 1, constant: 0)
        let subLabelTopConstraint = NSLayoutConstraint(item: subLabel, attribute: .Top, relatedBy: .Equal, toItem: mainLabel, attribute: .Bottom, multiplier: 1, constant: 0)
        let subLabelWidthConstraint = NSLayoutConstraint(item: subLabel, attribute: .Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: subLabel.superview, attribute: .Width, multiplier: 0.5, constant: 0)
        labelPositionConstraints.extend([subLabelLeadingConstraint, subLabelTopConstraint])
        labelSizeConstraints.append(subLabelWidthConstraint)
        
        // Detail label constraints are made such that it appears on the right side of the cell similar to right detail style cells. It also has a width constraint similar to the main and sub labels.
        
        // Add constraints to position and size the detail label.
        detailLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        let detailLabelTrailingConstraint = NSLayoutConstraint(item: detailLabel, attribute: .Trailing, relatedBy: .Equal, toItem: detailLabel.superview, attribute: .Trailing, multiplier: 1, constant: -2)
        let detailLabelCenterYConstraint = NSLayoutConstraint(item: detailLabel, attribute: .CenterY, relatedBy: .Equal, toItem: detailLabel.superview, attribute: .CenterY, multiplier: 1, constant: 0)
        let detailLabelWidthConstraint = NSLayoutConstraint(item: detailLabel, attribute: .Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: detailLabel.superview, attribute: .Width, multiplier: 0.5, constant: 0)
        labelPositionConstraints.extend([detailLabelTrailingConstraint, detailLabelCenterYConstraint])
        labelSizeConstraints.append(detailLabelWidthConstraint)
        
        // Add all constraints.
        addConstraints(labelPositionConstraints)
        addConstraints(labelSizeConstraints)
    }
    
    /**
        Removes the width constraint from the specified label. If the label is not the `mainLabel`, `subLabel`, or `detailLabel`, the method does nothing.
    
        :param: label The label to remove the width constraint from.
    */
    func removeWidthConstraint(onLabel label: UILabel) {
        // Find width constraint.
        let widthConstraint = labelSizeConstraints.filter({
            let itemMatch = $0.firstItem as? UILabel == label
            let attributeMatch = $0.firstAttribute == .Width
            return itemMatch && attributeMatch
        }).first
        
        // If width constraint is found, remove it.
        if let widthConstraint = widthConstraint {
            removeConstraint(widthConstraint)
            let index = find(labelSizeConstraints, widthConstraint)!
            labelSizeConstraints.removeAtIndex(index)
        }
    }
    
    /**
        Removes all width constraints on the labels.
    */
    func removeAllWidthConstraints() {
        removeConstraints(labelSizeConstraints)
        labelSizeConstraints.removeAll(keepCapacity: false)
    }
}
