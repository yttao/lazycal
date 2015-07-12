//
//  ChangeEventViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/9/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class ChangeEventViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {

    private let calendar = NSCalendar.currentCalendar()
    
    private var date: NSDate?
    
    private let eventDateFormatter = NSDateFormatter()
    
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventDateStartMainLabel: UILabel!
    
    @IBOutlet weak var eventDateStartDetailsLabel: UILabel!
    
    private let eventDateStartPicker = UIDatePicker()
    private let eventDateEndPicker = UIDatePicker()
    
    @IBOutlet weak var eventDateEndMainLabel: UILabel!
    @IBOutlet weak var eventDateEndDetailsLabel: UILabel!
    
    
    private var selectedIndexPath: NSIndexPath?
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        eventNameTextField.userInteractionEnabled = false
        
        eventDateStartPicker.date = date!
        
        eventDateFormatter.dateFormat = "MMM dd, yyyy"
        eventDateStartMainLabel.text = eventDateFormatter.stringFromDate(date!)
        eventDateStartPicker.addTarget(self, action: "updateEventDateStartLabels", forControlEvents:
            .ValueChanged)
        
        let hour = NSTimeInterval(3600)
        let nextHourDate = date!.dateByAddingTimeInterval(hour)
        eventDateEndPicker.date = nextHourDate
        eventDateEndPicker.addTarget(self, action: "updateEventDateEndLabels", forControlEvents: .ValueChanged)
        
        eventDateEndMainLabel.text = eventDateFormatter.stringFromDate(date!)
        
        // Format details labels
        eventDateFormatter.dateFormat = "h:mm a"
        eventDateStartDetailsLabel.text = eventDateFormatter.stringFromDate(date!)
        eventDateEndDetailsLabel.text = eventDateFormatter.stringFromDate(nextHourDate)
    }
    
    func setInitialDate(date: NSDate) {
        self.date = date
    }

    func updateEventDateStartLabels() {
        println("Updating all start labels")
        eventDateFormatter.dateFormat = "MMM dd, yyyy"
        eventDateStartMainLabel.text = eventDateFormatter.stringFromDate(eventDateStartPicker.date)
        
        eventDateFormatter.dateFormat = "h:mm a"
        eventDateStartDetailsLabel.text = eventDateFormatter.stringFromDate(eventDateStartPicker.date)
    }
    
    func updateEventDateEndLabels() {
        println("Updating all end labels")
        eventDateFormatter.dateFormat = "MMM dd, yyyy"
        eventDateEndMainLabel.text = eventDateFormatter.stringFromDate(eventDateEndPicker.date)
        
        eventDateFormatter.dateFormat = "h:mm a"
        eventDateEndDetailsLabel.text = eventDateFormatter.stringFromDate(eventDateEndPicker.date)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("***Selected: \(indexPath)***")
        println("Selected index: \(selectedIndexPath)")
        switch indexPath.section {
        case 0:
            selectedIndexPath = indexPath
            
            tableView.reloadData()
            eventNameTextField.userInteractionEnabled = true
            eventNameTextField.becomeFirstResponder()
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        case 1:
            selectedIndexPath = indexPath
            
            // Add date picker
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            
            eventDateStartMainLabel.hidden = true
            eventDateStartDetailsLabel.hidden = true
            cell.contentView.addSubview(eventDateStartPicker)
            cell.contentView.didAddSubview(eventDateStartPicker)
            
            // Recalculate height to display date picker
            tableView.reloadData()
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        case 2:
            selectedIndexPath = indexPath
            
            eventDateEndMainLabel.hidden = true
            eventDateEndDetailsLabel.hidden = true
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            //dateToLabel.removeFromSuperview()
            cell.contentView.addSubview(eventDateEndPicker)
            cell.contentView.didAddSubview(eventDateEndPicker)
            
            tableView.reloadData()
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        println("***Deselected: \(indexPath)***")
        switch indexPath.section {
        case 0:
            eventNameTextField.userInteractionEnabled = false
            eventNameTextField.resignFirstResponder()
        case 1:
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            eventDateStartPicker.removeFromSuperview()
            eventDateStartMainLabel.hidden = false
            eventDateStartDetailsLabel.hidden = false
        case 2:
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            eventDateEndPicker.removeFromSuperview()
            eventDateEndMainLabel.hidden = false
            eventDateEndDetailsLabel.hidden = false
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if selectedIndexPath == indexPath {
                let cell = UITableViewCell()
                return cell.frame.height
            }
            else {
                let cell = UITableViewCell()
                return cell.frame.height
            }
        case 1:
            if selectedIndexPath == indexPath {
                let datePickerHeight = eventDateStartPicker.frame.size.height
                return CGFloat(datePickerHeight)
            }
            else {
                let cell = UITableViewCell()
                return cell.frame.height
            }
        case 2:
            if selectedIndexPath == indexPath {
                let datePickerHeight = eventDateEndPicker.frame.size.height
                return CGFloat(datePickerHeight)
            }
            else {
                let cell = UITableViewCell()
                return cell.frame.height
            }
        default:
            let cell = UITableViewCell()
            return cell.frame.height
        }
    }
    
    /*override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }*/

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
