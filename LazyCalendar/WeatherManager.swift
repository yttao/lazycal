//
//  WeatherManager.swift
//  LazyCalendar
//
//  Created by Ying Tao on 9/5/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import Foundation
import CoreLocation

class WeatherManager: NSObject {
    // Weather manager singleton
    static let sharedManager = WeatherManager()
    
    static let apiKey = "51a1ae4dae2e4c9088466cb91e0b985a"
    
    /**
        Gets the weather data for a given time and performs the given response after getting the data.
    
        :param: coordinate The coordinate of the location to get the data from.
        :param: date The date from which to get the data.
        :param: completionHandler The `ServiceResponse` to handle the weather data.
    */
    func getWeatherData(coordinate: CLLocationCoordinate2D, date: NSDate? = nil, completionHandler: ServiceResponse) {
        // Make url for get request to Forecast.
        var urlString = "https://api.forecast.io/forecast/\(WeatherManager.apiKey)/\(coordinate.latitude),\(coordinate.longitude)"
        // Optionally include date (in UNIX time)
        if let date = date {
            urlString += ",\(Int(date.timeIntervalSince1970))"
        }
        println(urlString)
        
        // Make get request.
        RestApiManager.sharedInstance.makeHTTPGetRequest(urlString, completionHandler: completionHandler)
    }
}