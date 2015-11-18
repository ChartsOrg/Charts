//
//  RealmBarDataSet.swift
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

public class RealmBarDataSet: RealmBarLineScatterCandleBubbleDataSet, IBarChartDataSet
{
    private func initialize()
    {
        self.highlightColor = UIColor.blackColor()
    }
    
    public required init()
    {
        super.init()
    }
    
    public override init(results: RLMResults?, yValueField: String, xIndexField: String, label: String?)
    {
        super.init(results: results, yValueField: yValueField, xIndexField: xIndexField, label: label)
        initialize()
    }
    
    public init(results: RLMResults?, yValueField: String, xIndexField: String, stackValueField: String, label: String?)
    {
        _stackValueField = stackValueField
        
        super.init(results: results, yValueField: yValueField, xIndexField: xIndexField, label: label)
        initialize()
    }
    
    public convenience init(results: RLMResults?, yValueField: String, xIndexField: String)
    {
        self.init(results: results, yValueField: yValueField, xIndexField: xIndexField, label: "DataSet")
    }
    
    public convenience init(results: RLMResults?, yValueField: String, xIndexField: String, stackValueField: String)
    {
        self.init(results: results, yValueField: yValueField, xIndexField: xIndexField, stackValueField: stackValueField, label: "DataSet")
    }
    
    public override init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, xIndexField: String, label: String?)
    {
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, yValueField: yValueField, xIndexField: xIndexField, label: label)
        initialize()
    }
    
    public init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, xIndexField: String, stackValueField: String, label: String?)
    {
        _stackValueField = stackValueField
        
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, yValueField: yValueField, xIndexField: xIndexField, label: label)
        initialize()
    }
    
    public override func notifyDataSetChanged()
    {
        _cache.removeAll()
        ensureCache(start: 0, end: entryCount - 1)
        self.calcStackSize(_cache as! [BarChartDataEntry])
        
        super.notifyDataSetChanged()
    }
    
    // MARK: - Data functions and accessors
    
    internal var _stackValueField: String?
    
    /// the maximum number of bars that are stacked upon each other, this value
    /// is calculated from the Entries that are added to the DataSet
    private var _stackSize = 1
    
    internal override func buildEntryFromResultObject(object: RLMObject) -> ChartDataEntry
    {
        let value = object[_yValueField!]
        let entry: BarChartDataEntry
        
        if value is RLMArray
        {
            var values = [Double]()
            for val in value as! RLMArray
            {
                values.append((val as! RLMObject)[_stackValueField!] as! Double)
            }
            entry = BarChartDataEntry(values: values, xIndex: object[_xIndexField!] as! Int)
        }
        else
        {
            entry = BarChartDataEntry(value: value as! Double, xIndex: object[_xIndexField!] as! Int)
        }
        
        return entry
    }
    
    /// calculates the maximum stacksize that occurs in the Entries array of this DataSet
    private func calcStackSize(yVals: [BarChartDataEntry]!)
    {
        for (var i = 0; i < yVals.count; i++)
        {
            if let vals = yVals[i].values
            {
                if vals.count > _stackSize
                {
                    _stackSize = vals.count
                }
            }
        }
    }
    
    public override func calcMinMax(start start : Int, end: Int)
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
        _lastEnd = endValue
        
        _yMin = DBL_MAX
        _yMax = -DBL_MAX
        
        for (var i = start; i <= endValue; i++)
        {
            if let e = _cache[i - _cacheFirst] as? BarChartDataEntry
            {
                if !e.value.isNaN
                {
                    if e.values == nil
                    {
                        if e.value < _yMin
                        {
                            _yMin = e.value
                        }
                        
                        if e.value > _yMax
                        {
                            _yMax = e.value
                        }
                    }
                    else
                    {
                        if -e.negativeSum < _yMin
                        {
                            _yMin = -e.negativeSum
                        }
                        
                        if e.positiveSum > _yMax
                        {
                            _yMax = e.positiveSum
                        }
                    }
                }
            }
        }
        
        if (_yMin == DBL_MAX)
        {
            _yMin = 0.0
            _yMax = 0.0
        }
    }
    
    /// - returns: the maximum number of bars that can be stacked upon another in this DataSet.
    public var stackSize: Int
    {
        return _stackSize
    }
    
    /// - returns: true if this DataSet is stacked (stacksize > 1) or not.
    public var isStacked: Bool
    {
        return _stackSize > 1 ? true : false
    }
    
    /// array of labels used to describe the different values of the stacked bars
    public var stackLabels: [String] = ["Stack"]
    
    // MARK: - Styling functions and accessors
    
    /// space indicator between the bars in percentage of the whole width of one value (0.15 == 15% of bar width)
    public var barSpace: CGFloat = 0.15
    
    /// the color used for drawing the bar-shadows. The bar shadows is a surface behind the bar that indicates the maximum value
    public var barShadowColor = UIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0)
    
    /// the alpha value (transparency) that is used for drawing the highlight indicator bar. min = 0.0 (fully transparent), max = 1.0 (fully opaque)
    public var highlightAlpha = CGFloat(120.0 / 255.0)
    
    // MARK: - NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RealmBarDataSet
        copy._stackSize = _stackSize
        copy.stackLabels = stackLabels
        copy.barSpace = barSpace
        copy.barShadowColor = barShadowColor
        copy.highlightAlpha = highlightAlpha
        return copy
    }
}