//
//  SearchTableView.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/12/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class SearchTableView: UITableView {
    // Scale factor used by search table views.
    static let sizingScaleFactor: CGFloat = 3.0 / 4.0

    var searchResults: [AnyObject]!
    var searchController: UISearchController?
    var searchText: String? {
        return searchController?.searchBar.text
    }
    
    // Table view controller that displays selected results. If results do not need to be displayed, this is nil.
    var selectedResultsTableViewController: UITableViewController?
    
    var reuseIdentifier: String!
    
    var maxSearchResults = 5
    
    /**
        Initializes the view.
    
        :param: reuseIdentifier The cell reuse identifier.
    */
    func initializeView(reuseIdentifier: String) {
        // Set reuse identifier and register search table view cell so it can be reused.
        self.reuseIdentifier = reuseIdentifier
        registerClass(SearchTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // Set delegate and data source.
        delegate = self
        dataSource = self
        
        // Remove insets to get rid of automatic 15 left inset spacing.
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
    }
    
    /**
        Loads initial data.
        
        :param: selectedResultsTableViewController The table view controller that displays the selected results.
        :param: searchController The search controller.
    */
    func loadData(#selectedResultsTableViewController: UITableViewController, searchController: SearchController) {
        self.selectedResultsTableViewController = selectedResultsTableViewController
        self.searchController = searchController
    }
    
    /**
        Update the table view height and reload the data.
    */
    override func reloadData() {
        updateTableViewHeight()
        super.reloadData()
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
    
    /**
        Filters the search results.
    */
    func filterSearchResults() {
        assert(false, "filterSearchResults must be implemented by a subclass.")
    }
}

// MARK: - UITableViewDelegate
extension SearchTableView: UITableViewDelegate {
    // MARK: - Methods for setting up heights.
    /**
        The height of a cell is equal to 2/3 the height of a standard `UITableViewCell`.
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewCell().frame.height * SearchTableView.sizingScaleFactor
    }
}

// MARK: - UITableViewDataSource
extension SearchTableView: UITableViewDataSource {
    // MARK: - Methods for number of sections and rows.
    
    /**
        There is one section in the table view.
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
        The number of rows is the number of search results if it is less than or equal to the maximum number of search results. Otherwise, the number of rows is the maximum number of search results.
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResults.count <= maxSearchResults {
            return searchResults.count
        }
        return maxSearchResults
    }
    
    // MARK: - Methods for cell creation.
    
    /**
        The cell is a `SearchTableViewCell`.
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return dequeueReusableCellWithIdentifier(reuseIdentifier) as! SearchTableViewCell
    }
}

extension SearchTableView: SearchControllerDelegate {
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