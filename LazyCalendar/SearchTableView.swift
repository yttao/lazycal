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
    
    var searchController: SearchController!
    var selectedResultsTableViewController: UITableViewController!
    
    var reuseIdentifier: String!
    
    var maxSearchResults = 5
    
    func loadData(#selectedResultsTableViewController: UITableViewController, searchController: SearchController) {
        self.selectedResultsTableViewController = selectedResultsTableViewController
        self.searchController = searchController
    }
}