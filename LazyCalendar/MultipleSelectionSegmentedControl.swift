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
    
    // Segmented control corner radius
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    // Animation time on pressing button
    var animationTime = 0.3
    
    // MARK: - Initializers
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        momentary = false
        
        addTarget(self, action: "toggleSegment", forControlEvents: .ValueChanged)
        
        cornerRadius = 4
        clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        momentary = false
        
        addTarget(self, action: "toggleSegment", forControlEvents: .ValueChanged)
        
        cornerRadius = 4
        clipsToBounds = true
    }
    
    override init(items: [AnyObject]) {
        super.init(items: items)
        
        momentary = false
        
        addTarget(self, action: "toggleSegment", forControlEvents: .ValueChanged)
        
        cornerRadius = 4
        clipsToBounds = true
    }
    
    // MARK: - Methods related to selection.
    
    /**
        Toggles the segment that was just touched on or off.
    */
    func toggleSegment() {
        // Toggle segment
        if !contains(selectedSegmentIndices, selectedSegmentIndex) {
            // If not already in the selected segments, select the segment.
            selectSegment(atIndex: selectedSegmentIndex)
        }
        else {
            // Else if already selected, deselect the segment.
            deselectSegment(atIndex: selectedSegmentIndex)
        }
    }
    
    /**
        Selects the segment at an index.
    
        :param: index The index of the segment to select.
    */
    func selectSegment(atIndex index: Int) {
        let sortedSegments = sortedSegmentsByXCoordinate()
        let segment = sortedSegments[selectedSegmentIndex]
        
        UIView.animateWithDuration(animationTime, animations: {
            segment.layer.backgroundColor = self.tintColor.CGColor
        })
        
        selectedSegmentIndices.insert(index)
        
        selectedSegmentIndex = -1
    }
    
    /**
        Deselects teh segment at an index.
    
        :param: index The index of the segment to deselect.
    */
    func deselectSegment(atIndex index: Int) {
        let deselectedSegmentIndex = index
        let sortedSegments = sortedSegmentsByXCoordinate()
        let segment = sortedSegments[deselectedSegmentIndex]
        
        UIView.animateWithDuration(animationTime, animations: {
            segment.layer.backgroundColor = self.backgroundColor?.CGColor ?? UIColor.clearColor().CGColor
        })
        
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
}
