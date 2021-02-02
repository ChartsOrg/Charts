//
//  Range.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class Range: NSObject
{
    open var from: Double
    open var to: Double
    
    public init(from: Double, to: Double)
    {
        self.from = from
        self.to = to
        
        super.init()
    }

    /// - Parameters:
    ///   - value:
    /// - Returns: `true` if this range contains (if the value is in between) the given value, `false` ifnot.
    open func contains(_ value: Double) -> Bool
    {
        if value > from && value <= to
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    open func isLarger(_ value: Double) -> Bool
    {
        return value > to
    }
    
    open func isSmaller(_ value: Double) -> Bool
    {
        return value < from
    }
}
