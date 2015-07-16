//
//  MonthItemTableViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/15/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import CoreData

class MonthItemTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {

    private var events = [NSManagedObject]()
    
    private let reuseIdentifier = "EventCell"
    
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as? EventTableViewCell
        println(cell)
        
        println(events.count)
        println(indexPath.row)
        let event = events[indexPath.row]
        println(event)
        if event.valueForKey("name") as? String != nil {
            //cell!.textLabel!.text = event.valueForKey("name") as? String
            cell?.eventNameLabel.text = event.valueForKey("name") as? String
        }
        
        
        return cell!
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewCell().frame.height
    }
    
    
    // Show events in table form for a date
    func showEvents(date: NSDate) {
        println("Showing events for \(date)")
        // Find events for that date
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("TestEvent", inManagedObjectContext: managedContext)!
        
        // Create fetch request for data
        let fetchRequest = NSFetchRequest(entityName: "TestEvent")
        
        // Format for finding data
        //let predicate = NSPredicate(format: "(dateStart LIKE '\(date)')", argumentArray: nil)
        //fetchRequest.predicate = predicate
        
        
        // Execute fetch request
        var error: NSError? = nil
        events = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]
        
        // Display events (no order for now)
        tableView.reloadData()
    }
}