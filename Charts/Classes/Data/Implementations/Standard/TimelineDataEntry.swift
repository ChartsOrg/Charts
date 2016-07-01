//
//  TimelineDataEntry.swift
//  Charts
//
//  Created by 迅牛 on 16/6/30.
//  Copyright © 2016年 dcg. All rights reserved.
//

import UIKit

public class TimelineDataEntry: CandleChartDataEntry {
    
    public var current:Double = 0.0
    internal var _range:Double = 0.0
    public var volume:Double = 0.0
    public var money:Double = 0.0
    public var avg:Double {
        
        if volume == 0 {
            return 0
        }
        return money / volume
    }
    
    public var range:Double {
        return _range/100.0;
    }
    
    override public var value:Double {
        
        get {
            
            return current;
        } set {
            current = newValue;
        }

    }
    
    public required init()
    {
        super.init()
    }
    public override init(xIndex: Int, shadowH: Double, shadowL: Double, open: Double, close: Double)
    {
        super.init(xIndex: xIndex, shadowH: shadowH, shadowL: shadowL, open: open, close: close)
    }
    
    public override init(xIndex: Int, shadowH: Double, shadowL: Double, open: Double, close: Double, data: AnyObject?)
    {
        super.init(xIndex: xIndex, shadowH: shadowH, shadowL: shadowL, open: open, close: close, data:data)
    }
    
    
    public init(xIndex: Int, shadowH: Double, shadowL: Double, open: Double, close: Double, current:Double, range:Double, volume:Double, money:Double) {
        self.volume = volume;
        self.money = money
        self.current = current
        self._range = range
        super.init(xIndex: xIndex, shadowH: shadowH, shadowL: shadowL, open: open, close: close)
    }
    
    public init(xIndex: Int, shadowH: Double, shadowL: Double, open: Double, close: Double, current:Double, range:Double, volume:Double, money:Double, data: AnyObject?) {
        self.volume = volume;
        self.money = money
        self.current = current
        self._range = range
        super.init(xIndex: xIndex, shadowH: shadowH, shadowL: shadowL, open: open, close: close)
    }
}
