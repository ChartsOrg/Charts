//
//  CandleChartDataSet.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


public class CandleChartDataSet: LineScatterCandleRadarChartDataSet, ICandleChartDataSet
{
    
    public required init()
    {
        super.init()
    }
    
    public override init(values: [ChartDataEntry]?, label: String?)
    {
        super.init(values: values, label: label)
    }
    
    // MARK: - Data functions and accessors
    
    public override func calcMinMax(entry e: ChartDataEntry)
    {
        guard let e = e as? CandleChartDataEntry
            else { return }
        
        if (e.low < _yMin)
        {
            _yMin = e.low
        }
        
        if (e.high > _yMax)
        {
            _yMax = e.high
        }
        
        calcMinMaxX(entry: e)
    }
    
    // MARK: - Styling functions and accessors
    
    /// the space between the candle entries
    ///
    /// **default**: 0.1 (10%)
    private var _barSpace = CGFloat(0.1)
    
    /// the space that is left out on the left and right side of each candle,
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
    
    /// should the candle bars show?
    /// when false, only "ticks" will show
    ///
    /// **default**: true
    public var showCandleBar: Bool = true
    
    /// the width of the candle-shadow-line in pixels.
    ///
    /// **default**: 1.5
    public var shadowWidth = CGFloat(1.5)
    
    /// the color of the shadow line
    public var shadowColor: NSUIColor?
    
    /// use candle color for the shadow
    public var shadowColorSameAsCandle = false
    
    /// Is the shadow color same as the candle color?
    public var isShadowColorSameAsCandle: Bool { return shadowColorSameAsCandle }
    
    /// color for open == close
    public var neutralColor: NSUIColor?
    
    /// color for open > close
    public var increasingColor: NSUIColor?
    
    /// color for open < close
    public var decreasingColor: NSUIColor?
    
    /// Are increasing values drawn as filled?
    /// increasing candlesticks are traditionally hollow
    public var increasingFilled = false
    
    /// Are increasing values drawn as filled?
    public var isIncreasingFilled: Bool { return increasingFilled }
    
    /// Are decreasing values drawn as filled?
    /// descreasing candlesticks are traditionally filled
    public var decreasingFilled = true
    
    /// Are decreasing values drawn as filled?
    public var isDecreasingFilled: Bool { return decreasingFilled }
}