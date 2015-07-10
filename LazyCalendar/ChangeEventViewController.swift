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
    
    @IBOutlet weak var eventNameTextField: UITextField!
    
    private let eventDateStartPicker = UIDatePicker()
    private let eventDateEndPicker = UIDatePicker()
    
    private var selectedIndexPath: NSIndexPath?
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventDateStartPicker.date = date!
        
        let hour = NSTimeInterval(3600)
        let nextHourDate = date!.dateByAddingTimeInterval(hour)
        eventDateEndPicker.date = nextHourDate
        
        eventNameTextField.userInteractionEnabled = false
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func setInitialDate(date: NSDate) {
        println("Set date to: \(date)")
        self.date = date
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Selected: \(indexPath)")
        println("Selected index: \(selectedIndexPath)")
        println("Case \(indexPath.section)")
        switch indexPath.section {
        case 0:
            if selectedIndexPath != nil && selectedIndexPath != indexPath {
                println("Deselecting \(selectedIndexPath)")
                tableView.deselectRowAtIndexPath(selectedIndexPath!, animated: false)
                
                let oldIndexPath = selectedIndexPath
                selectedIndexPath = indexPath
                tableView.reloadRowsAtIndexPaths([oldIndexPath!], withRowAnimation: .None)
            }
            else {
                selectedIndexPath = indexPath
            }
            
            //println("Selecting...")
            eventNameTextField.userInteractionEnabled = true
            eventNameTextField.becomeFirstResponder()
            /*tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition:
                .None)*/
        case 1:
            if selectedIndexPath != nil && selectedIndexPath != indexPath {
                println("Deselecting \(selectedIndexPath)")
                tableView.deselectRowAtIndexPath(selectedIndexPath!, animated: false)
                
                let oldIndexPath = selectedIndexPath
                selectedIndexPath = indexPath
                tableView.reloadRowsAtIndexPaths([oldIndexPath!], withRowAnimation: .None)
            }
            else {
                selectedIndexPath = indexPath
            }
            
            // Add date picker
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.contentView.addSubview(eventDateStartPicker)
            
            // Recalculate height to display date picker
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition:
                .None)
        case 2:
            if selectedIndexPath != nil && selectedIndexPath != indexPath {
                println("Deselecting \(selectedIndexPath)")
                tableView.deselectRowAtIndexPath(selectedIndexPath!, animated: false)
            }
            selectedIndexPath = indexPath
            
            // Add date picker
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.contentView.addSubview(eventDateEndPicker)
            
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition:
                .None)
            // Recalculate height to display date picker
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        println("Deselecting...")
        switch indexPath.section {
        case 0:
            eventNameTextField.userInteractionEnabled = false
            eventNameTextField.resignFirstResponder()
        case 1:
            // Recalculate height to hide date picker
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            let subviews = cell.contentView.subviews
            eventDateStartPicker.removeFromSuperview()
            //println("Reloading after removing: \(indexPath)")
            //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        case 2:
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            let subviews = cell.contentView.subviews
            eventDateEndPicker.removeFromSuperview()
            //println("Reloading after removing: \(indexPath)")
            //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell()
            return cell.frame.height
        case 1:
            if (selectedIndexPath == indexPath) {
                //println("Calculating selected height for \(indexPath.section)")
                let datePickerHeight = eventDateStartPicker.frame.size.height
                return CGFloat(datePickerHeight)
            }
            else {
                //println("Calculating unselected height for \(indexPath.section)")
                let cell = UITableViewCell()
                return cell.frame.height
            }
        case 2:
            if (selectedIndexPath == indexPath) {
                //println("Calculating selected height for \(indexPath.section)")
                let datePickerHeight = eventDateEndPicker.frame.size.height
                return CGFloat(datePickerHeight)
            }
            else {
                //println("Calculating unselected height for \(indexPath.section)")
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
