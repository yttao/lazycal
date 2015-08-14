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
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        let searchTextField = searchBar.valueForKey("_searchField") as? UITextField
        
        // Inform the delegate that the search text field size has been calculated.
        if let searchTextField = searchTextField {
            searchControllerDelegate?.searchControllerDidLoadSearchTextField(searchTextField)
        }
    }
}

// MARK: - SearchControllerDelegate
protocol SearchControllerDelegate {
    func searchControllerDidLoadSearchTextField(searchTextField: UITextField)
}