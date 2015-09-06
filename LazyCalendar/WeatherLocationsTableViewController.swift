//
//  WeatherLocationsTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 9/5/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class WeatherLocationsTableViewController: UITableViewController {
    var event: LZEvent!
    
    let reuseIdentifier = "WeatherLocationCell"
    
    // MARK: - Methods for initializing data.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    /**
        Loads initial data into the table view controller.
    */
    func loadData(event: LZEvent) {
        self.event = event
    }
    
    /**
        Shows the weather details view controller.
    */
    func showWeatherDetailsViewController(location: LZLocation) {
        let weatherDetailsNavigationController = storyboard!.instantiateViewControllerWithIdentifier("WeatherDetailsNavigationController") as! UINavigationController
        let weatherDetailsViewController = weatherDetailsNavigationController.topViewController as! WeatherDetailsViewController
        weatherDetailsViewController.loadData(location)
        navigationController!.showViewController(weatherDetailsViewController, sender: self)
    }
}

extension WeatherLocationsTableViewController: UITableViewDelegate {
    /**
        When a cell is selected, it shows the weather details table view controller.
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = event.storedLocations[indexPath.row] as! LZLocation
        showWeatherDetailsViewController(location)
    }
}

extension WeatherLocationsTableViewController: UITableViewDataSource {
    /**
        There is one section in the table view.
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
        The number of rows is the number of event locations.
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event.storedLocations.count
    }
    
    /**
        Each cell lists the name of the place in it.
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! UITableViewCell
        let location = event.storedLocations[indexPath.row] as! LZLocation
        if let name = location.name {
            cell.textLabel?.text = name
        }
        else {
            cell.textLabel?.text = " "
        }
        return cell
    }
}