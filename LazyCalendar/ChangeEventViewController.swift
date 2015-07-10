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
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
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
        println("***Selected: \(indexPath)***")
        println("Selected index: \(selectedIndexPath)")
        switch indexPath.section {
        case 0:
            if selectedIndexPath != nil {
                tableView.reloadRowsAtIndexPaths([selectedIndexPath!], withRowAnimation: .None)
            }
            selectedIndexPath = indexPath
            
            eventNameTextField.userInteractionEnabled = true
            eventNameTextField.becomeFirstResponder()
            //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            /*tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition:
                .None)*/
        case 1:
            if selectedIndexPath != nil {
                tableView.reloadRowsAtIndexPaths([selectedIndexPath!], withRowAnimation: .None)
            }
            selectedIndexPath = indexPath
            
            // Add date picker
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.contentView.addSubview(eventDateStartPicker)
            cell.contentView.didAddSubview(eventDateStartPicker)
            
            // Recalculate height to display date picker
            println("Reloading data")
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            println("Cell height at end: \(cell.frame.height)")
        case 2:
            if selectedIndexPath != nil {
                tableView.reloadRowsAtIndexPaths([selectedIndexPath!], withRowAnimation: .None)
            }
            selectedIndexPath = indexPath
            
            // Add date picker
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.contentView.addSubview(eventDateEndPicker)
            cell.contentView.didAddSubview(eventDateEndPicker)
            
            println("Reloading data")
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            println("Cell height at end: \(cell.frame.height)")
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        println("***Deselected: \(indexPath)***")
        println("Selected: \(selectedIndexPath)")
        switch indexPath.section {
        case 0:
            eventNameTextField.userInteractionEnabled = false
            eventNameTextField.resignFirstResponder()
        case 1:
            eventDateStartPicker.removeFromSuperview()
            //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        case 2:
            eventDateEndPicker.removeFromSuperview()
            //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if selectedIndexPath == indexPath {
                println("Selected height: \(indexPath)")
                let cell = UITableViewCell()
                return cell.frame.height
            }
            else {
                println("Unselected height: \(indexPath)")
                let cell = UITableViewCell()
                return cell.frame.height
            }
        case 1:
            if selectedIndexPath == indexPath {
                println("Selected height: \(indexPath)")
                let datePickerHeight = eventDateStartPicker.frame.size.height
                return CGFloat(datePickerHeight)
            }
            else {
                println("Unselected height: \(indexPath)")
                let cell = UITableViewCell()
                return cell.frame.height
            }
        case 2:
            if selectedIndexPath == indexPath {
                println("Selected height: \(indexPath)")
                let datePickerHeight = eventDateEndPicker.frame.size.height
                return CGFloat(datePickerHeight)
            }
            else {
                println("Unselected height: \(indexPath)")
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
