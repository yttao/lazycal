//
//  CalendarCollectionViewCell.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/12/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
