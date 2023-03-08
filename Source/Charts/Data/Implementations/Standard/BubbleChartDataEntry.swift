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
    @objc open var size = CGFloat(0.0)
    
    public required init()
    {
        super.init()
    }
    
    /// - Parameters:
    ///   - x: The index on the x-axis.
    ///   - y: The value on the y-axis.
    ///   - size: The size of the bubble.
    @objc public init(x: Double, y: Double, size: CGFloat)
    {
        super.init(x: x, y: y)
        
        self.size = size
    }
    
    /// - Parameters:
    ///   - x: The index on the x-axis.
    ///   - y: The value on the y-axis.
    ///   - size: The size of the bubble.
    ///   - data: Spot for additional data this Entry represents.
    @objc public init(x: Double, y: Double, size: CGFloat, data: AnyObject?)
    {
        super.init(x: x, y: y, data: data)
        
        self.size = size
    }
    
    /// - Parameters:
    ///   - x: The index on the x-axis.
    ///   - y: The value on the y-axis.
    ///   - size: The size of the bubble.
    ///   - icon: icon image
    @objc public init(x: Double, y: Double, size: CGFloat, icon: NSUIImage?)
    {
        super.init(x: x, y: y, icon: icon)
        
        self.size = size
    }
    
    /// - Parameters:
    ///   - x: The index on the x-axis.
    ///   - y: The value on the y-axis.
    ///   - size: The size of the bubble.
    ///   - icon: icon image
    ///   - data: Spot for additional data this Entry represents.
    @objc public init(x: Double, y: Double, size: CGFloat, icon: NSUIImage?, data: AnyObject?)
    {
        super.init(x: x, y: y, icon: icon, data: data)
        
        self.size = size
    }
    
    // MARK: NSCopying
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! BubbleChartDataEntry
        copy.size = size
        return copy
    }
}
