//
//  RestApiManager.swift
//  LazyCalendar
//
//  Created by Ying Tao on 9/5/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import Foundation

typealias ServiceResponse = (json: JSON, error: NSError?) -> Void

class RestApiManager: NSObject {
    // REST API manager singleton
    static let sharedInstance = RestApiManager()
    
    /**
        Makes an HTTP get request to a URL.
    
        :param: urlString A URL string.
        :param: completionHandler The `ServiceResponse` to initiate when the data is received.
    */
    func makeHTTPGetRequest(urlString: String, completionHandler: ServiceResponse) {
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        // Open session to get data.
        let session = NSURLSession.sharedSession()
        
        // Create task with completion handler after data retrieval.
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            let json = JSON(data: data)
            completionHandler(json: json, error: error)
        })
        
        // Start get request.
        task.resume()
    }
}