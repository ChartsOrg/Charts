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

@objc(ChartRange)
public class Range: NSObject
{
    public var from: Double
    public var to: Double
    
    public init(from: Double, to: Double)
    {
        self.from = from
        self.to = to
        
        super.init()
    }

    /// - returns: `true` if this range contains (if the value is in between) the given value, `false` ifnot.
    /// - parameter value:
    public func contains(value: Double) -> Bool
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
    
    public func isLarger(value: Double) -> Bool
    {
        return value > to
    }
    
    public func isSmaller(value: Double) -> Bool
    {
        return value < from
    }
}