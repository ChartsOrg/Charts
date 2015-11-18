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
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit
import Realm
import Realm.Dynamic

public class RealmCandleDataSet: RealmLineScatterCandleRadarDataSet, ICandleChartDataSet
{
    public required init()
    {
        super.init()
    }

    public init(results: RLMResults?, highField: String, lowField: String, openField: String, closeField: String, xIndexField: String, label: String?)
    {
        _highField = highField
        _lowField = lowField
        _openField = openField
        _closeField = closeField
        
        super.init(results: results, yValueField: "", xIndexField: xIndexField, label: label)
    }
    
    public convenience init(results: RLMResults?, highField: String, lowField: String, openField: String, closeField: String, xIndexField: String)
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
    
    public override func calcMinMax(start start: Int, end: Int)
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
        
        for (var i = start; i <= endValue; i++)
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
    private var _bodySpace = CGFloat(0.1)
    
    /// the space that is left out on the left and right side of each candle,
    /// **default**: 0.1 (10%), max 0.45, min 0.0
    public var bodySpace: CGFloat
    {
        set
        {
            if (newValue < 0.0)
            {
                _bodySpace = 0.0
            }
            else if (newValue > 0.45)
            {
                _bodySpace = 0.45
            }
            else
            {
                _bodySpace = newValue
            }
        }
        get
        {
            return _bodySpace
        }
    }
    
    /// the width of the candle-shadow-line in pixels.
    ///
    /// **default**: 3.0
    public var shadowWidth = CGFloat(1.5)
    
    /// the color of the shadow line
    public var shadowColor: UIColor?
    
    /// use candle color for the shadow
    public var shadowColorSameAsCandle = false
    
    /// Is the shadow color same as the candle color?
    public var isShadowColorSameAsCandle: Bool { return shadowColorSameAsCandle }
    
    /// color for open <= close
    public var decreasingColor: UIColor?
    
    /// color for open > close
    public var increasingColor: UIColor?
    
    /// Are decreasing values drawn as filled?
    public var decreasingFilled = false
    
    /// Are decreasing values drawn as filled?
    public var isDecreasingFilled: Bool { return decreasingFilled }
    
    /// Are increasing values drawn as filled?
    public var increasingFilled = true
    
    /// Are increasing values drawn as filled?
    public var isIncreasingFilled: Bool { return increasingFilled }
}