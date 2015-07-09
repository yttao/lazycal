//
//  ChangeEventViewController.swift
//  LazyCalendar
//
//  Created by Ying Tao on 7/9/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class ChangeEventViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {

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
        selectedIndexPath = indexPath
        switch indexPath.section {
        case 0:
            eventNameTextField.userInteractionEnabled = true
            eventNameTextField.becomeFirstResponder()
        case 1:
            // Add date picker
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.contentView.addSubview(eventDateStartPicker)
            cell.contentView.didAddSubview(eventDateStartPicker)
            
            // Recalculate height to display date picker
            tableView.reloadSections(NSIndexSet(index: indexPath.section),withRowAnimation: .None)
            tableView.reloadData()
        case 2:
            // Add date picker
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.contentView.addSubview(eventDateEndPicker)
            cell.contentView.didAddSubview(eventDateEndPicker)
            
            // Recalculate height to display date picker
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .None)
            tableView.reloadData()
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            println("Deselected \(indexPath.section)")
            // Recalculate height to hide date picker
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            let subviews = cell.contentView.subviews
            for subview in subviews {
                if subview as? UIDatePicker != nil && subview as! UIDatePicker == eventDateStartPicker {
                    subview.removeFromSuperview()
                }
            }
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            if (selectedIndexPath == indexPath) {
                let datePickerHeight = eventDateStartPicker.frame.size.height
                return CGFloat(datePickerHeight)
            }
            else {
                let cell = UITableViewCell()
                return cell.frame.height
            }
        case 2:
            if (selectedIndexPath == indexPath) {
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
