//
//  ChartDataEntry.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

public class ChartDataEntry: ChartDataEntryBase
{
    /// the x value
    public var x = Double(0.0)
    
    public required init()
    {
        super.init()
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    public init(x: Double, y: Double)
    {
        super.init(y: y)
        
        self.x = x
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter data: Space for additional data this Entry represents.

    public init(x: Double, y: Double, data: AnyObject?)
    {
        super.init(y: y)
        
        self.x = x

        self.data = data
    }
    
    // MARK: NSObject
    
    public override func isEqual(object: AnyObject?) -> Bool
    {
        if !super.isEqual(object)
        {
            return false
        }
        
        if fabs(object!.x - x) > DBL_EPSILON
        {
            return false
        }
        
        return true
    }
    
    // MARK: NSObject
    
    public override var description: String
    {
        return "ChartDataEntry, x: \(x), y \(y)"
    }
    
    // MARK: NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = self.dynamicType.init()
        
        copy.x = x
        copy.y = y
        copy.data = data
        
        return copy
    }
}

public func ==(lhs: ChartDataEntry, rhs: ChartDataEntry) -> Bool
{
    if lhs === rhs
    {
        return true
    }
    
    if !lhs.isKindOfClass(rhs.dynamicType)
    {
        return false
    }
    
    if lhs.data !== rhs.data && !lhs.data!.isEqual(rhs.data)
    {
        return false
    }
    
    if fabs(lhs.x - rhs.x) > DBL_EPSILON
    {
        return false
    }
    
    if fabs(lhs.y - rhs.y) > DBL_EPSILON
    {
        return false
    }
    
    return true
}