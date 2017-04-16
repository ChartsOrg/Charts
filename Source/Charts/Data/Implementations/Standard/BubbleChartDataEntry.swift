//
//  BubbleDataEntry.swift
//  Charts
//
//  Bubble chart implementation: 
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

open class BubbleChartDataEntry: ChartDataEntry
{
    /// The size of the bubble.
    open var size = CGFloat(0.0)
    
    public required init()
    {
        super.init()
    }
    
    /// - parameter x: The index on the x-axis.
    /// - parameter y: The value on the y-axis.
    /// - parameter size: The size of the bubble.
    public init(x: Double, y: Double, size: CGFloat)
    {
        super.init(x: x, y: y)
        
        self.size = size
    }
    
    /// - parameter x: The index on the x-axis.
    /// - parameter y: The value on the y-axis.
    /// - parameter size: The size of the bubble.
    /// - parameter data: Spot for additional data this Entry represents.
    public init(x: Double, y: Double, size: CGFloat, data: AnyObject?)
    {
        super.init(x: x, y: y, data: data)
        
        self.size = size
    }
    
    /// - parameter x: The index on the x-axis.
    /// - parameter y: The value on the y-axis.
    /// - parameter size: The size of the bubble.
    /// - parameter icon: icon image
    public init(x: Double, y: Double, size: CGFloat, icon: NSUIImage?)
    {
        super.init(x: x, y: y, icon: icon)
        
        self.size = size
    }
    
    /// - parameter x: The index on the x-axis.
    /// - parameter y: The value on the y-axis.
    /// - parameter size: The size of the bubble.
    /// - parameter icon: icon image
    /// - parameter data: Spot for additional data this Entry represents.
    public init(x: Double, y: Double, size: CGFloat, icon: NSUIImage?, data: AnyObject?)
    {
        super.init(x: x, y: y, icon: icon, data: data)
        
        self.size = size
    }
    
    // MARK: NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! BubbleChartDataEntry
        copy.size = size
        return copy
    }
}
