//
//  ChartDataEntryBase.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class ChartDataEntryBase: NSObject
{
    /// the y value
    open var y = Double(0.0)
    
    /// optional spot for additional data this Entry represents
    open var data: AnyObject?
    
    public override required init()
    {
        super.init()
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter y: the y value (the actual value of the entry)
    public init(y: Double)
    {
        super.init()
        
        self.y = y
    }
    
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter data: Space for additional data this Entry represents.

    public init(y: Double, data: AnyObject?)
    {
        super.init()
        
        self.y = y
        self.data = data
    }
    
    // MARK: NSObject
    
    open override func isEqual(_ object: Any?) -> Bool
    {
        if object == nil
        {
            return false
        }
        
        if !(object! as AnyObject).isKind(of: type(of: self))
        {
            return false
        }
        
        if (object! as AnyObject).data !== data && !((object! as AnyObject).data??.isEqual(self.data))!
        {
            return false
        }
        
        if fabs((object! as AnyObject).y - y) > DBL_EPSILON
        {
            return false
        }
        
        return true
    }
    
    // MARK: NSObject
    
    open override var description: String
    {
        return "ChartDataEntryBase, y \(y)"
    }
}

public func ==(lhs: ChartDataEntryBase, rhs: ChartDataEntryBase) -> Bool
{
    if lhs === rhs
    {
        return true
    }
    
    if !lhs.isKind(of: type(of: rhs))
    {
        return false
    }
    
    if lhs.data !== rhs.data && !lhs.data!.isEqual(rhs.data)
    {
        return false
    }
    
    if fabs(lhs.y - rhs.y) > DBL_EPSILON
    {
        return false
    }
    
    return true
}
