//
//  MultipleSelectionSegmentedControl.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/15/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import QuartzCore

class MultipleSelectionSegmentedControl: UISegmentedControl {
    var selectedSegmentIndices = Set<Int>()
    
    var cornerRadius: CGFloat = 4.0
    
    // MARK: - Initializers
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        momentary = false
        
        addTarget(self, action: "toggleSegment", forControlEvents: .ValueChanged)
        
        layer.cornerRadius = cornerRadius
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        momentary = false
        
        addTarget(self, action: "toggleSegment", forControlEvents: .ValueChanged)
        
        layer.cornerRadius = cornerRadius
    }
    
    override init(items: [AnyObject]) {
        super.init(items: items)
        
        momentary = false
        
        addTarget(self, action: "toggleSegment", forControlEvents: .ValueChanged)
        
        layer.cornerRadius = cornerRadius
    }
    
    // MARK: - Methods related to selection.
    
    /**
        Toggles the segment that was just touched on or off.
    */
    func toggleSegment() {
        // Toggle segment
        if !contains(selectedSegmentIndices, selectedSegmentIndex) {
            selectSegment(atIndex: selectedSegmentIndex)
        }
        else {
            deselectSegment(atIndex: selectedSegmentIndex)
        }
    }
    
    /**
        Selects the segment at an index.
    */
    func selectSegment(atIndex index: Int) {
        println(selectedSegmentIndex)
        
        let sortedSegments = sortedSegmentsByXCoordinate()
        let segment = sortedSegments[selectedSegmentIndex]
        segment.removeFromSuperview()
        
        // Add animation for selection
        let animation = CATransition()
        animation.duration = 0.1
        animation.type = kCATransitionFade
        segment.layer.addAnimation(animation, forKey: nil)
        
        if segment == sortedSegments.first {
            let maskLayer = CAShapeLayer(layer: segment.layer)
            let maskPath = UIBezierPath(roundedRect: segment.bounds, byRoundingCorners: .BottomLeft | .TopLeft, cornerRadii: CGSizeMake(layer.cornerRadius, layer.cornerRadius))
            maskLayer.path = maskPath.CGPath
            segment.layer.mask = maskLayer
        }
        else if segment == sortedSegments.last {
            let maskLayer = CAShapeLayer(layer: segment.layer)
            let maskPath = UIBezierPath(roundedRect: segment.bounds, byRoundingCorners: .BottomRight | .TopRight, cornerRadii: CGSizeMake(layer.cornerRadius, layer.cornerRadius))
            maskLayer.path = maskPath.CGPath
            segment.layer.mask = maskLayer
        }
        segment.layer.opacity = layer.opacity
        segment.layer.backgroundColor = tintColor.CGColor
        
        addSubview(segment)
        didAddSubview(segment)
        
        selectedSegmentIndices.insert(index)
        
        selectedSegmentIndex = -1
    }
    
    // MARK: - Methods related to deselection.
    
    func deselectSegment(atIndex index: Int) {
        println(selectedSegmentIndex)
        let deselectedSegmentIndex = index
        let sortedSegments = sortedSegmentsByXCoordinate()
        let segment = sortedSegments[deselectedSegmentIndex]
        segment.removeFromSuperview()
        
        // Add animation for deselection
        let animation = CATransition()
        animation.duration = 0.1
        animation.type = kCATransitionFade
        segment.layer.addAnimation(animation, forKey: nil)
        
        if segment == sortedSegments.first {
            let maskLayer = CAShapeLayer(layer: segment.layer)
            let maskPath = UIBezierPath(roundedRect: segment.bounds, byRoundingCorners: .BottomLeft | .TopLeft, cornerRadii: CGSizeMake(layer.cornerRadius, layer.cornerRadius))
            maskLayer.path = maskPath.CGPath
            segment.layer.mask = maskLayer
        }
        else if segment == sortedSegments.last {
            let maskLayer = CAShapeLayer(layer: segment.layer)
            let maskPath = UIBezierPath(roundedRect: segment.bounds, byRoundingCorners: .BottomRight | .TopRight, cornerRadii: CGSizeMake(layer.cornerRadius, layer.cornerRadius))
            maskLayer.path = maskPath.CGPath
            segment.layer.mask = maskLayer
        }
        segment.layer.opacity = layer.opacity
        segment.layer.backgroundColor = UIColor.clearColor().CGColor
        
        addSubview(segment)
        didAddSubview(segment)
        
        selectedSegmentIndices.remove(index)
        
        selectedSegmentIndex = -1
    }
    
    /**
        Returns a `Bool` that determines if the segment at the index is selected.
        
        :param: index The index of the segment.
        :returns: `true` if the segment at the index is selected; `false` otherwise.
    */
    func selectedSegment(index: Int) -> Bool {
        return contains(selectedSegmentIndices, index)
    }
    
    /**
        Returns an array of segments (as `UIViews`)
    */
    func sortedSegmentsByXCoordinate() -> [UIView] {
        // Get UIViews from subviews
        let views = subviews.map({
            return $0 as! UIView
        })
        // Sort views by x coordinate
        let sortedViews = views.sorted({
            let firstX = $0.frame.origin.x
            let secondX = $1.frame.origin.x
            
            return firstX < secondX
        })
        return sortedViews
    }
    
    /**
        Returns an array of segments (as `UIViews`)
    */
    static func sortSegmentsByXCoordinate(control: UISegmentedControl) -> [UIView] {
        // Get UIViews from subviews
        let views = control.subviews.map({
            return $0 as! UIView
        })
        // Sort views by x coordinate
        let sortedViews = views.sorted({
            let firstX = $0.frame.origin.x
            let secondX = $1.frame.origin.x
            
            return firstX < secondX
        })
        return sortedViews
    }
}
