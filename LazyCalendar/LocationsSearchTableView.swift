//
//  LocationsSearchTableView.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/13/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import MapKit
import AddressBook
import AddressBookUI

class LocationsSearchTableView: SearchTableView {
    private var locationsTableViewController: LocationsTableViewController! {
        get {
            return selectedResultsTableViewController as! LocationsTableViewController
        }
        set {
            selectedResultsTableViewController = newValue
        }
    }
    private var filteredMapItems: [MapItem] {
        get {
            return searchResults as! [MapItem]
        }
        set {
            searchResults = newValue
        }
    }
    
    private var timer: NSTimer?
    
    // MARK: - Initializers
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeView()
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        initializeView()
    }
    
    private func initializeView() {
        // Set delegate and data source.
        delegate = self
        dataSource = self
        
        filteredMapItems = [MapItem]()
        
        reuseIdentifier = "LocationCell"
        registerClass(SearchTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // Remove insets to get rid of automatic 15 left inset spacing.
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
    }
    
    /**
        Loads initial data.
    
        :param: locationsTableViewController The `LocationsTableViewController` that contains this table view.
        :param: searchController The search controller.
    */
    override func loadData(#selectedResultsTableViewController: UITableViewController, searchController: SearchController) {
        self.locationsTableViewController = selectedResultsTableViewController as! LocationsTableViewController
        self.searchController = searchController
    }
    
    /**
        Filters the search results by the text entered in the search bar.
    
        :param: timer The `NSTimer` controlling when the search request fires.
    */
    func filterLocations(timer: NSTimer) {
        let searchText = timer.userInfo as? String

        if searchText != nil && searchText != "" {
            // Create search request.
            let request = MKLocalSearchRequest()
            // Set text to search for.
            request.naturalLanguageQuery = searchText
            // Set location to begin searching from.
            request.region = locationsTableViewController.mapView!.region
            
            // Search for string.
            let search = MKLocalSearch(request: request)
            search.startWithCompletionHandler() {
                (response: MKLocalSearchResponse!, error: NSError!) in
                if error != nil {
                    // Error warning
                    NSLog("Error occurred when searching: %@", error.localizedDescription)
                }
                else {
                    // Get MKMapItems that were found.
                    let mkMapItems = response.mapItems as! [MKMapItem]
                    // Convert to [MapItem]
                    let mapItems = mkMapItems.map({
                        return MapItem(coordinate: $0.placemark.coordinate, name: $0.name, address: self.stringFromAddressDictionary($0.placemark.addressDictionary))
                    })
                    // Show only MapItems that aren't already present in selected map items.
                    self.filteredMapItems = mapItems.filter({
                        !contains(self.locationsTableViewController.selectedMapItems, $0)
                    })
                }
                self.updateTableViewHeight()
                self.reloadData()
            }
        }
        else {
            filteredMapItems.removeAll(keepCapacity: false)
            self.updateTableViewHeight()
            reloadData()
        }
    }
    
    // MARK: - Methods for formatting data.
    
    /**
        Makes an address string out of the available information in the address dictionary.
    
        The address string is created in two steps:
    
        * Create a multiline address with all information.
    
        The address string created by `ABCreateStringWithAddressDictionary:` is a multiline address usually created the following format (if any parts of the address are unavailable, they do not appear):
    
        Street address
    
        City State Zip code
    
        Country
    
        * Replace newlines with spaces.
    
        The newlines are then replaced with spaces using `stringByReplacingOccurrencesOfString:withString:` because the `subtitle` property of `MKAnnotation` can only display single line strings.
    
        :param: addressDictionary A dictionary of address information.
    */
    private func stringFromAddressDictionary(addressDictionary: [NSObject: AnyObject]) -> String {
        return ABCreateStringWithAddressDictionary(addressDictionary, false).stringByReplacingOccurrencesOfString("\n", withString: " ")
    }
    
    /**
        Bolds the search bar text in the result cells.
    
        :param: cell The cell to have bolded text.
    */
    func boldSearchTextInLabel(label: UILabel) {
        let text = label.text!
        let searchText = searchController!.searchBar.text
        
        // Find range of search text
        let boldRange = text.rangeOfString(searchText, options: .CaseInsensitiveSearch)
        
        // Check if search text is in label (can be in main or details label depending on where search text was found).
        if boldRange != nil {
            let start = distance(text.startIndex, boldRange!.startIndex)
            let length = count(searchText)
            let range = NSMakeRange(start, length)
            
            // Make bold font
            let font = UIFont.boldSystemFontOfSize(label.font.pointSize)
            
            // Create attributed text
            var attributedText = NSMutableAttributedString(string: text)
            attributedText.beginEditing()
            attributedText.addAttribute(NSFontAttributeName, value: font, range: range)
            attributedText.endEditing()
            
            // Set text
            label.attributedText = attributedText
        }
            // If search text is not in label, show label with plain text.
        else {
            label.attributedText = nil
            label.text = text
        }
    }
    
    /**
        Updates the table view height. The table view height is calculated to equal the height of all the cells.
    */
    func updateTableViewHeight() {
        var newHeight: CGFloat = 0.0
        for i in 0..<tableView(self, numberOfRowsInSection: 0) {
            newHeight += tableView(self, heightForRowAtIndexPath: NSIndexPath(forRow: i, inSection: 0))
        }
        let newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, newHeight)
        frame = newFrame
    }
}

// MARK: - UITableViewDelegate
extension LocationsSearchTableView: UITableViewDelegate {
    // MARK: - Methods related to selecting cells.
    
    /**
        Selection will append to selected locations and clear the search bar.
    
        The filter ensures that search results will not show locations that are already selected, so this method cannot add duplicate locations.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mapItem = filteredMapItems[indexPath.row]
        locationsTableViewController.addNewMapItem(mapItem)
        searchController.searchBar.text = nil
    }
}

// MARK: - UITableViewDataSource
extension LocationsSearchTableView: UITableViewDataSource {
    // MARK: - Methods for setting up amount of sections and cells.
    
    /**
        There is one section in the table view.
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
        The number of rows is the number of search results.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(filteredMapItems.count)
        if filteredMapItems.count <= maxSearchResults {
            return filteredMapItems.count
        }
        return maxSearchResults
    }
    
    /**
        The height of a cell is equal to 2/3 the height of a standard `UITableViewCell`.
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewCell().frame.height * SearchTableView.sizingScaleFactor
    }
    
    // MARK: - Methods for setting up cell content.
    
    /**
        Display cell with name as text label and address as detail text label.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! SearchTableViewCell
        
        let mapItem = filteredMapItems[indexPath.row]
        let name = mapItem.name
        let address = mapItem.address
        cell.mainLabel.text = name
        cell.subLabel.text = address
        boldSearchTextInLabel(cell.mainLabel)
        
        return cell
    }
}

// MARK: - UISearchResultsUpdating
extension LocationsSearchTableView: UISearchResultsUpdating {
    /**
        When the search bar is activated or the text in the search bar changes, start updating search results.
    
        Search results are controlled by an NSTimer. Whenever this function is called, the last timer used is invalidated in order to prevent sending previous search requests when the text to search has changed. Then, it begins a new timer that waits 0.3 seconds before starting a search request.
    */
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Destroy last request and make a new one
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "filterLocations:", userInfo: searchController.searchBar.text, repeats: false)
        updateTableViewHeight()
        reloadData()
    }
}

// MARK: - SearchControllerDelegate
extension LocationsSearchTableView: SearchControllerDelegate {
    /**
        When the text field of the search controller loads, set the offset so that it matches the text field's offset and resize the contacts search table width to be the same as the text field.
    */
    func searchControllerDidLoadSearchTextField(searchTextField: UITextField) {
        // Simulate cancel button size.
        let cancelButton = UIButton()
        cancelButton.titleLabel!.text = "Cancel"
        cancelButton.titleLabel!.sizeToFit()
        
        // Resize width to search text field's width minus the size of the cancel button.
        let newFrame = CGRectMake(searchTextField.frame.origin.x, frame.origin.y, searchTextField.frame.width - cancelButton.titleLabel!.frame.width - searchTextField.frame.origin.x, frame.height)
        frame = newFrame
    }
}
