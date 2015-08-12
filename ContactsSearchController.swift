//
//  SearchTextField.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/12/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import Foundation
import UIKit

class SearchController: UISearchController {
    // Custom delegate
    var searchControllerDelegate: SearchControllerDelegate?
    
    // MARK: - Initializers
    
    /*required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(searchResultsController: UIViewController!) {
        super.init(searchResultsController: searchResultsController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }*/
    
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

/**
*/
protocol SearchControllerDelegate {
    func searchControllerDidLoadSearchTextField(searchTextField: UITextField)
}