//
//  CandleChartDataEntry.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

public class CandleChartDataEntry: ChartDataEntry
{
    /// shadow-high value
    public var high = Double(0.0)
    
    /// shadow-low value
    public var low = Double(0.0)
    
    /// close value
    public var close = Double(0.0)
    
    /// open value
    public var open = Double(0.0)
    
    public required init()
    {
        super.init()
    }
    
    public init(x: Double, shadowH: Double, shadowL: Double, open: Double, close: Double)
    {
        super.init(x: x, y: (shadowH + shadowL) / 2.0)
        
        self.high = shadowH
        self.low = shadowL
        self.open = open
        self.close = close
    }
    
    public init(x: Double, shadowH: Double, shadowL: Double, open: Double, close: Double, data: AnyObject?)
    {
        super.init(x: x, y: (shadowH + shadowL) / 2.0, data: data)
        
        self.high = shadowH
        self.low = shadowL
        self.open = open
        self.close = close
    }
    
    /// - returns: The overall range (difference) between shadow-high and shadow-low.
    public var shadowRange: Double
    {
        return abs(high - low)
    }
    
    /// - returns: The body size (difference between open and close).
    public var bodyRange: Double
    {
        return abs(open - close)
    }
    
    /// the center value of the candle. (Middle value between high and low)
    public override var y: Double
    {
        get
        {
            return super.y
        }
        set
        {
            super.y = (high + low) / 2.0
        }
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! CandleChartDataEntry
        copy.high = high
        copy.high = low
        copy.high = open
        copy.high = close
        return copy
    }
}