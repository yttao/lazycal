//
//  MonthItemHeader.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/1/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class MonthItemHeaderView: UICollectionReusableView {
    @IBOutlet weak var headerLabel: UILabel!
    
    func setLabel(dateComponents: NSDateComponents) {
        headerLabel.text = "\(dateComponents.month)"
    }
}
