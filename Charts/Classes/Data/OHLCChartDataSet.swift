//
//  OHLCChartDataSet.swift
//  Charts
//  
//
//  Created by John Casley on 10/22/15.
//  Based on CandleChartDataSet by Daniel Cohen Gindi
//  Copyright © 2015 John Casley. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public class OHLCChartDataSet: LineScatterCandleChartDataSet
{
    /// width of bar in pixels
    /// **default**: 3.0
    public var barWidth = CGFloat(1.5)
    
    /// space between the bar entries
    /// **default**: 0.1 (10%)
    private var _barSpace = CGFloat(0.1)
    
    /// bar color
    public var barColor: UIColor?
    
    /// color for neutral bar
    public var neutralColor: UIColor?
    
    /// color for open < close
    public var decreasingColor: UIColor?
    
    /// color for close > open
    public var increasingColor: UIColor?
    
    public required init()
    {
        super.init()
    }
    
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
        
        var entries = yVals as! [OHLCChartDataEntry]
        
        var endValue : Int
        
        if end == 0 || end >= entries.count
        {
            endValue = entries.count - 1
        }
        else
        {
            endValue = end
        }
        
        _lastStart = start
        _lastEnd = end
        
        _yMin = DBL_MAX
        _yMax = -DBL_MAX
        
        for (var i = start; i <= endValue; i++)
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
    
    /// the space that is left out on the left and right side of each bar,
    /// **default**: 0.1 (10%), max 0.45, min 0.0
    public var barSpace: CGFloat
    {
        set
        {
            if (newValue < 0.0)
            {
                _barSpace = 0.0
            }
            else if (newValue > 0.45)
            {
                _barSpace = 0.45
            }
            else
            {
                _barSpace = newValue
            }
        }
        
        get
        {
            return _barSpace
        }
    }
    
}