//
//  LocationsViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/3/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import MapKit

class LocationsViewController: UIViewController {
    @IBOutlet weak var locationsTableViewContainer: UIView!
    @IBOutlet weak var locationsMapViewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initializeHeightConstraints()
    }
    
    /**
        Initialize height constraints on the map view. The height constraints are determined by device size while the table view container takes up the remaining space.
    
        The map's height is 1/3 of the screen.
    */
    func initializeHeightConstraints() {
        let heightConstraint = NSLayoutConstraint(item: locationsMapViewContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: view.frame.height / 3)
        locationsMapViewContainer.addConstraint(heightConstraint)
    }
}
