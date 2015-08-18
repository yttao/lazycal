//
//  SearchTextField.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/12/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class SearchController: UISearchController {
    // Custom delegate
    var searchControllerDelegate: SearchControllerDelegate?

    // MARK: - Initialization of search controller
    
    /**
        When the search controller will appear, notify the delegate that the search text field loaded.
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Inform the delegate that the search text field size has been calculated.
        if let searchTextField = searchBar.valueForKey("_searchField") as? UITextField {
            searchControllerDelegate?.searchControllerDidLoadSearchTextField(searchTextField)
        }
    }
}

// MARK: - SearchControllerDelegate
protocol SearchControllerDelegate {
    func searchControllerDidLoadSearchTextField(searchTextField: UITextField)
}