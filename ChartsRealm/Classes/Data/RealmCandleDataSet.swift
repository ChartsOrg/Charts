//
//  RealmCandleDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

import Charts
import Realm
import Realm.Dynamic

open class RealmCandleDataSet: RealmLineScatterCandleRadarDataSet, ICandleChartDataSet
{
    open override func initialize()
    {

    }
    
    public required init()
    {
        super.init()
    }

    public init(results: RLMResults<RLMObject>?, highField: String, lowField: String, openField: String, closeField: String, xIndexField: String, label: String?)
    {
        _highField = highField
        _lowField = lowField
        _openField = openField
        _closeField = closeField
        
        super.init(results: results, yValueField: "", xIndexField: xIndexField, label: label)
    }
    
    public convenience init(results: RLMResults<RLMObject>?, highField: String, lowField: String, openField: String, closeField: String, xIndexField: String)
    {
        self.init(results: results, highField: highField, lowField: lowField, openField: openField, closeField: closeField, xIndexField: xIndexField, label: "DataSet")
    }
    
    public init(realm: RLMRealm?, modelName: String, resultsWhere: String, highField: String, lowField: String, openField: String, closeField: String, xIndexField: String, label: String?)
    {
        _highField = highField
        _lowField = lowField
        _openField = openField
        _closeField = closeField
        
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, yValueField: "", xIndexField: xIndexField, label: label)
    }
    
    // MARK: - Data functions and accessors
    
    internal var _highField: String?
    internal var _lowField: String?
    internal var _openField: String?
    internal var _closeField: String?
    
    internal override func buildEntryFromResultObject(_ object: RLMObject, atIndex: UInt) -> ChartDataEntry
    {
        let entry = CandleChartDataEntry(
            xIndex: _xIndexField == nil ? Int(atIndex) : object[_xIndexField!] as! Int,
            shadowH: object[_highField!] as! Double,
            shadowL: object[_lowField!] as! Double,
            open: object[_openField!] as! Double,
            close: object[_closeField!] as! Double)
        
        return entry
    }
    
    open override func calcMinMax(start: Int, end: Int)
    {
        let yValCount = self.entryCount
        
        if yValCount == 0
        {
            return
        }
        
        var endValue : Int
        
        if end == 0 || end >= yValCount
        {
            endValue = yValCount - 1
        }
        else
        {
            endValue = end
        }
        
        ensureCache(start: start, end: endValue)
        
        if _cache.count == 0
        {
            return
        }
        
        _lastStart = start
        _lastEnd = end
        
        _yMin = DBL_MAX
        _yMax = -DBL_MAX
        
        for i in stride(from: start, through: endValue, by: 1)
        {
            let e = _cache[i - _cacheFirst] as! CandleChartDataEntry
            
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
    
    // MARK: - Styling functions and accessors
    
    /// the space between the candle entries
    ///
    /// **default**: 0.1 (10%)
    private var _barSpace = CGFloat(0.1)
    
    /// the space that is left out on the left and right side of each candle,
    /// **default**: 0.1 (10%), max 0.45, min 0.0
    open var barSpace: CGFloat
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
    open var showCandleBar: Bool = true
    
    /// the width of the candle-shadow-line in pixels.
    ///
    /// **default**: 3.0
    open var shadowWidth = CGFloat(1.5)
    
    /// the color of the shadow line
    open var shadowColor: NSUIColor?
    
    /// use candle color for the shadow
    open var shadowColorSameAsCandle = false
    
    /// Is the shadow color same as the candle color?
    open var isShadowColorSameAsCandle: Bool { return shadowColorSameAsCandle }
    
    /// color for open == close
    open var neutralColor: NSUIColor?
    
    /// color for open > close
    open var increasingColor: NSUIColor?
    
    /// color for open < close
    open var decreasingColor: NSUIColor?
    
    /// Are increasing values drawn as filled?
    /// increasing candlesticks are traditionally hollow
    open var increasingFilled = false
    
    /// Are increasing values drawn as filled?
    open var isIncreasingFilled: Bool { return increasingFilled }
    
    /// Are decreasing values drawn as filled?
    /// descreasing candlesticks are traditionally filled
    open var decreasingFilled = true
    
    /// Are decreasing values drawn as filled?
    open var isDecreasingFilled: Bool { return decreasingFilled }
}
