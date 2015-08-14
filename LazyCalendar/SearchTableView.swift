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
    static let sizingScaleFactor: CGFloat = 2.0 / 3.0
    
    var searchResults: [AnyObject]!
    
    var searchController: UISearchController?
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
}

extension SearchTableView: UITableViewDelegate {
    
}

extension SearchTableView: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection(section)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cellForRowAtIndexPath(indexPath)!
    }
}