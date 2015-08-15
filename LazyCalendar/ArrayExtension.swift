//
//  ArrayExtension.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/15/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import Foundation

extension Array {
    /**
        Returns an `Array` containing the elements `x` of `self` for which the value is not nil.
    
        :param: array The `Array` to filter `nil` from.
        :returns: An `Array` containing the elements of `array` that were not `nil`.
    */
    static func filterNils(array: [T?]) -> [T] {
        return array.filter({
            $0 != nil
            }).map({
                return $0!
            })
    }
    
}