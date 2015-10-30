//
//  OHLCChartDataEntry.swift
//  Charts
//
//  Created by John Casley on 10/22/15.
//  Copyright © 2015 John Casley. All rights reserved.
//

import Foundation

public class OHLCChartDataEntry: ChartDataEntry
{
    public var high = Double(0.0)
    public var low = Double(0.0)
    public var close = Double(0.0)
    public var open = Double(0.0)
    
    public required init()
    {
        super.init()
    }
    
    public init(xIndex: Int, high: Double, low: Double, open: Double, close: Double)
    {
        super.init(value: (high + low) / 2.0, xIndex: xIndex)
        
        self.high = high
        self.low = low
        self.open = open
        self.close = close
    }
    
    public init(xIndex: Int, high: Double, low: Double, open: Double, close: Double, data: AnyObject?)
    {
        super.init(value: (high + low) / 2.0, xIndex: xIndex, data: data)
        
        self.high = high
        self.low = low
        self.open = open
        self.close = close
    }
    
    /// return range of bar
    public var barRange: Double
    {
        return abs(high - low)
    }
    
    /// return midpoint of bar
    public override var value: Double
    {
        get
        {
            return super.value
        }
        
        set
        {
            super.value = (high + low) / 2.0
        }
    }
    
    /// MARK: NSCopying
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! OHLCChartDataEntry
        copy.high = high
        copy.low = low
        copy.open = open
        copy.close = close
        return copy
    }
}