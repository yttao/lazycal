//
//  WeatherDetailsItemView.swift
//  LazyCalendar
//
//  Created by Ying Tao on 9/5/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class WeatherDetailsItemView: UIView {
    // UIView margin constant value
    static let marginConstant: CGFloat = 8.0
    // Width & height of image
    static let conditionImageDimension: CGFloat = 43.0
    static let precipitationImageDimension: CGFloat = 21.0
    static let labelToViewScale: CGFloat = 0.1
    static let smallImageToViewScale: CGFloat = 0.1
    static let largeImageToViewScale: CGFloat = 0.2
    static let marginScale: CGFloat = 0.05, topMarginScale: CGFloat = 0.15, bottomMarginScale : CGFloat = 0.15
    
    var imageScalingSize: CGFloat {
        if frame.size.height > frame.size.width {
            return frame.size.height
        }
        else {
            return frame.size.width
        }
    }
    
    let timeLabel = UILabel(), temperatureLabel = UILabel(), precipitationLabel = UILabel()
    let conditionImage = UIImageView(), precipitationImage = UIImageView(image: UIImage(named: "1441487273_weather-rainy-h.png"))
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        timeLabel.text = "foo"
        temperatureLabel.text = "bar"
        precipitationLabel.text = "bat"
        conditionImage.image = UIImage(named: "1441487273_weather-rainy-h.png")
        
        addSubviews()
        
        initializeConstraints()
    }
    
    /**
        Adds all the components of the view as subviews.
    */
    func addSubviews() {
        addSubview(timeLabel)
        addSubview(conditionImage)
        addSubview(temperatureLabel)
        addSubview(precipitationImage)
        addSubview(precipitationLabel)
    }
    
    /**
        Initializes the constraints on the subviews.
    */
    func initializeConstraints() {
        initializeTimeLabelConstraints()
        initializeConditionImageConstraints()
        initializeTemperatureLabelConstraints()
        initializePrecipitationImageConstraints()
        initializePrecipitationLabelConstraints()
    }
    
    /**
        Initializes the time label constraints.
    */
    func initializeTimeLabelConstraints() {
        timeLabel.textAlignment = .Center
        timeLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let centerXConstraint = NSLayoutConstraint(item: timeLabel, attribute: .CenterX, relatedBy: .Equal, toItem: timeLabel.superview, attribute: .CenterX, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: timeLabel, attribute: .Top, relatedBy: .Equal, toItem: timeLabel.superview, attribute: .Top, multiplier: 1, constant: WeatherDetailsItemView.topMarginScale * frame.size.height)
        let widthConstraint = NSLayoutConstraint(item: timeLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: WeatherDetailsItemView.labelToViewScale * frame.size.width)
        let heightConstraint = NSLayoutConstraint(item: timeLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: WeatherDetailsItemView.labelToViewScale * frame.size.height)
        
        addConstraints([centerXConstraint, topConstraint])
    }
    
    /**
        Initializes the precipitation image constraints.
    */
    func initializeConditionImageConstraints() {
        conditionImage.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let topConstraint = NSLayoutConstraint(item: conditionImage, attribute: .Top, relatedBy: .Equal, toItem: timeLabel, attribute: .Bottom, multiplier: 1, constant: WeatherDetailsItemView.marginScale * frame.height)
        let centerXConstraint = NSLayoutConstraint(item: conditionImage, attribute: .CenterX, relatedBy: .Equal, toItem: conditionImage.superview, attribute: .CenterX, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: conditionImage, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: WeatherDetailsItemView.largeImageToViewScale * imageScalingSize)
        let heightConstraint = NSLayoutConstraint(item: conditionImage, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: WeatherDetailsItemView.largeImageToViewScale * imageScalingSize)
        
        conditionImage.addConstraints([widthConstraint, heightConstraint])
        addConstraints([topConstraint, centerXConstraint])
    }
    
    /**
        Initializes the temperature label constraints.
    */
    func initializeTemperatureLabelConstraints() {
        temperatureLabel.textAlignment = .Center
        temperatureLabel.setTranslatesAutoresizingMaskIntoConstraints(false)

        let centerXConstraint = NSLayoutConstraint(item: temperatureLabel, attribute: .CenterX, relatedBy: .Equal, toItem: temperatureLabel.superview, attribute: .CenterX, multiplier: 1, constant: 0)
        
        addConstraints([centerXConstraint])
    }
    
    /**
        Initializes the precipitation image constraints.
    */
    func initializePrecipitationImageConstraints() {
        precipitationImage.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let centerXConstraint = NSLayoutConstraint(item: precipitationImage, attribute: .Trailing, relatedBy: .Equal, toItem: precipitationImage.superview, attribute: .CenterX, multiplier: 1, constant: -WeatherDetailsItemView.marginScale * frame.width)
        let topConstraint = NSLayoutConstraint(item: precipitationImage, attribute: .Top, relatedBy: .Equal, toItem: temperatureLabel, attribute: .Bottom, multiplier: 1, constant: WeatherDetailsItemView.marginScale * 2 * frame.height)
        let bottomConstraint = NSLayoutConstraint(item: precipitationImage, attribute: .Bottom, relatedBy: .Equal, toItem: precipitationImage.superview, attribute: .Bottom, multiplier: 1, constant: -WeatherDetailsItemView.bottomMarginScale * frame.height)
        
        let widthConstraint = NSLayoutConstraint(item: precipitationImage, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: WeatherDetailsItemView.smallImageToViewScale * imageScalingSize)
        let heightConstraint = NSLayoutConstraint(item: precipitationImage, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: WeatherDetailsItemView.smallImageToViewScale * imageScalingSize)
        
        precipitationImage.addConstraints([widthConstraint, heightConstraint])
        addConstraints([topConstraint, bottomConstraint, centerXConstraint])
    }
    
    /** 
        Initializes the precipitation label constraints.
    */
    func initializePrecipitationLabelConstraints() {
        precipitationLabel.textAlignment = .Center
        precipitationLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let centerXConstraint = NSLayoutConstraint(item: precipitationLabel, attribute: .Leading, relatedBy: .Equal, toItem: precipitationLabel.superview, attribute: .CenterX, multiplier: 1, constant: WeatherDetailsItemView.marginScale * 2 * frame.width)
        let topConstraint = NSLayoutConstraint(item: precipitationLabel, attribute: .Top, relatedBy: .Equal, toItem: temperatureLabel, attribute: .Bottom, multiplier: 1, constant: WeatherDetailsItemView.marginScale * 2 * frame.height)
        let bottomConstraint = NSLayoutConstraint(item: precipitationLabel, attribute: .Bottom, relatedBy: .Equal, toItem: precipitationLabel.superview, attribute: .Bottom, multiplier: 1, constant: -WeatherDetailsItemView.bottomMarginScale * frame.height)
        
        addConstraints([topConstraint, bottomConstraint, centerXConstraint])
    }
    
    /**
        Sets the condition for the weather item.
    */
    func setCondition(condition: String) {
        
    }
}
