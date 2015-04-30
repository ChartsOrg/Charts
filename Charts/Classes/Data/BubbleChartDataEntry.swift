//
//  BubbleDataEntry.swift
//  Charts
//
//  Bubble chart implementation: 
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation

public class BubbleChartDataEntry: ChartDataEntry
{
    /// size value
    public var size = Float(0.0)
    
    public init(xIndex: Int, value: Float, size: Float)
    {
        super.init(value: value, xIndex: xIndex)
        
        self.size = size
    }
    
    public init(xIndex: Int, value: Float, size: Float, data: AnyObject?)
    {
        super.init(value: value, xIndex: xIndex, data: data)
      
        self.size = size
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        var copy = super.copyWithZone(zone) as! BubbleChartDataEntry;
        copy.size = size;
        return copy;
    }
}