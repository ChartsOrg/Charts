//
//  CandleChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics
import UIKit

public class CandleChartDataSet: BarLineScatterCandleChartDataSet
{
    /// the width of the candle-shadow-line in pixels. 
    /// :default: 3.0
    public var shadowWidth = CGFloat(1.5)

    /// the space between the candle entries
    /// :default: 0.1 (10%)
    private var _bodySpace = CGFloat(0.1)
    
    /// the color of the shadow line
    public var shadowColor: UIColor?
    
    /// use candle color for the shadow
    public var makeShadowSameColorAsCandle = false
    
    /// color for open <= close
    public var decreasingColor: UIColor?
    
    /// color for open > close
    public var increasingColor: UIColor?
    
    /// Are decreasing values drawn as filled?
    public var decreasingFilled = false
    
    /// Are increasing values drawn as filled?
    public var increasingFilled = true
    
    public override init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init(yVals: yVals, label: label)
    }
    
    internal override func calcMinMax(start start: Int, end: Int)
    {
        if (yVals.count == 0)
        {
            return
        }
        
        var entries = yVals as! [CandleChartDataEntry]
        
        var endValue : Int
        
        if end == 0
        {
            endValue = entries.count - 1
        }
        else
        {
            endValue = end
        }
        
        _lastStart = start
        _lastEnd = end
        
        _yMin = entries[start].low
        _yMax = entries[start].high
        
        for (var i = start + 1; i <= endValue; i++)
        {
            let e = entries[i]
            
            if (e.low < _yMin)
            {
                _yMin = e.low
            }
            
            if (e.high > _yMax)
            {
                _yMax = e.high
            }
        }
    }

    /// the space that is left out on the left and right side of each candle,
    /// :default: 0.1 (10%), max 0.45, min 0.0
    public var bodySpace: CGFloat
    {
        set
        {
            _bodySpace = newValue
            
            if (_bodySpace < 0.0)
            {
                _bodySpace = 0.0
            }
            if (_bodySpace > 0.45)
            {
                _bodySpace = 0.45
            }
        }
        get
        {
            return _bodySpace
        }
    }
    
    /// Are increasing values drawn as filled?
    public var isIncreasingFilled: Bool { return increasingFilled; }
    
    /// Are decreasing values drawn as filled?
    public var isDecreasingFilled: Bool { return decreasingFilled; }
}