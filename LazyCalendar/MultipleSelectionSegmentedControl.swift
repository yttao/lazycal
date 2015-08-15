//
//  MultipleSelectionSegmentedControl.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/15/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit

class MultipleSelectionSegmentedControl: UISegmentedControl {
    var selectedSegmentIndices = Set<Int>()
    
    // MARK: - Initializers
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        momentary = false
        
        addTarget(self, action: "toggleSegment", forControlEvents: .ValueChanged)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        momentary = false
    }
    
    override init(items: [AnyObject]) {
        super.init(items: items)
        
        momentary = false
        for subview in subviews {
            let subview = subview as? UIView
            subview?.tintColor = UIColor.clearColor()
        }
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
        // Deselect index (to allow reselection later)
        selectedSegmentIndex = -1
    }
    
    /**
        Selects the segment at an index.
    */
    func selectSegment(atIndex index: Int) {
        selectedSegmentIndices.insert(index)
        
        let sortedSegments = sortedSegmentsByXCoordinate()
        
        for segment in sortedSegments {
            segment.removeFromSuperview()
            segment.backgroundColor = backgroundColor
        }
        
        for selectedSegmentIndex in selectedSegmentIndices {
            sortedSegments[selectedSegmentIndex].backgroundColor = tintColor
            sortedSegments[selectedSegmentIndex].tintColor = backgroundColor
        }
        
        for segment in sortedSegments {
            addSubview(segment)
            didAddSubview(segment)
        }
    }
    
    // MARK: - Methods related to deselection.
    
    func deselectSegment(atIndex index: Int) {
        selectedSegmentIndices.remove(index)
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
