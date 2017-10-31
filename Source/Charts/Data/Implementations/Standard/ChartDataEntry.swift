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

open class ChartDataEntry: ChartDataEntryBase
{
    /// the x value
    @objc open var x = Double(0.0)
    
    public required init()
    {
        super.init()
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    @objc public init(x: Double, y: Double)
    {
        super.init(y: y)
        
        self.x = x
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter data: Space for additional data this Entry represents.
    
    @objc public init(x: Double, y: Double, data: AnyObject?)
    {
        super.init(y: y)
        
        self.x = x
        
        self.data = data
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    
    @objc public init(x: Double, y: Double, icon: NSUIImage?)
    {
        super.init(y: y, icon: icon)
        
        self.x = x
    }
    
    /// An Entry represents one single entry in the chart.
    /// - parameter x: the x value
    /// - parameter y: the y value (the actual value of the entry)
    /// - parameter icon: icon image
    /// - parameter data: Space for additional data this Entry represents.
    
    @objc public init(x: Double, y: Double, icon: NSUIImage?, data: AnyObject?)
    {
        super.init(y: y, icon: icon, data: data)
        
        self.x = x
    }
    
    // MARK: NSObject
    
    open override func isEqual(_ object: Any?) -> Bool
    {
        if !super.isEqual(object)
        {
            return false
        }
        
        if fabs((object! as AnyObject).x - x) > Double.ulpOfOne
        {
            return false
        }
        
        return true
    }
    
    // MARK: NSObject
    
    open override var description: String
    {
        return "ChartDataEntry, x: \(x), y \(y)"
    }
    
    // MARK: NSCopying
    
    @objc open func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = type(of: self).init()
        
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
    
    if !lhs.isKind(of: type(of: rhs))
    {
        return false
    }
    
    if lhs.data !== rhs.data && !lhs.data!.isEqual(rhs.data)
    {
        return false
    }
    
    if fabs(lhs.x - rhs.x) > Double.ulpOfOne
    {
        return false
    }
    
    if fabs(lhs.y - rhs.y) > Double.ulpOfOne
    {
        return false
    }
    
    return true
}
