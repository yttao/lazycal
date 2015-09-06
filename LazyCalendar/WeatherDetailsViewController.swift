//
//  WeatherDetailsViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 9/5/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class WeatherDetailsViewController: UIViewController {
    var location: LZLocation?
    
    @IBOutlet weak var dailyScrollView: UIScrollView!
    @IBOutlet weak var hourlyScrollView: UIScrollView!
    @IBOutlet weak var detailsScrollView: UIScrollView!
    
    var dailyItems = [WeatherDetailsItemView]()
    var hourlyItems = [WeatherDetailsItemView]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func loadData(location: LZLocation) {
        self.location = location
    }
}