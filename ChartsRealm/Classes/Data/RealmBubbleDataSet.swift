//
//  RealmBubbleDataSet.swift
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

open class RealmBubbleDataSet: RealmBarLineScatterCandleBubbleDataSet, IBubbleChartDataSet
{
    open override func initialize()
    {
    }
    
    public required init()
    {
        super.init()
    }
    
    public init(results: RLMResults<RLMObject>?, yValueField: String, xIndexField: String, sizeField: String, label: String?)
    {
        _sizeField = sizeField
        
        super.init(results: results, yValueField: yValueField, xIndexField: xIndexField, label: label)
    }
    
    public convenience init(results: RLMResults<RLMObject>?, yValueField: String, xIndexField: String, sizeField: String)
    {
        self.init(results: results, yValueField: yValueField, xIndexField: xIndexField, sizeField: sizeField, label: "DataSet")
    }
    
    public init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, xIndexField: String, sizeField: String, label: String?)
    {
        _sizeField = sizeField
        
        super.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, yValueField: yValueField, xIndexField: xIndexField, label: label)
    }
    
    // MARK: - Data functions and accessors
    
    internal var _sizeField: String?
    
    internal var _xMax = Double(0.0)
    internal var _xMin = Double(0.0)
    internal var _maxSize = CGFloat(0.0)
    
    open var xMin: Double { return _xMin }
    open var xMax: Double { return _xMax }
    open var maxSize: CGFloat { return _maxSize }
    open var normalizeSizeEnabled: Bool = true
    open var isNormalizeSizeEnabled: Bool { return normalizeSizeEnabled }
    
    internal override func buildEntryFromResultObject(_ object: RLMObject, atIndex: UInt) -> ChartDataEntry
    {
        let entry = BubbleChartDataEntry(xIndex: _xIndexField == nil ? Int(atIndex) : object[_xIndexField!] as! Int, value: object[_yValueField!] as! Double, size: object[_sizeField!] as! CGFloat)
        
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
        
        _yMin = yMin(_cache[start - _cacheFirst] as! BubbleChartDataEntry)
        _yMax = yMax(_cache[start - _cacheFirst] as! BubbleChartDataEntry)
        
        for i in stride(from: start, through: endValue, by: 1)
        {
            let entry = _cache[i - _cacheFirst] as! BubbleChartDataEntry
            
            let ymin = yMin(entry)
            let ymax = yMax(entry)
            
            if (ymin < _yMin)
            {
                _yMin = ymin
            }
            
            if (ymax > _yMax)
            {
                _yMax = ymax
            }
            
            let xmin = xMin(entry)
            let xmax = xMax(entry)
            
            if (xmin < _xMin)
            {
                _xMin = xmin
            }
            
            if (xmax > _xMax)
            {
                _xMax = xmax
            }
            
            let size = largestSize(entry)
            
            if (size > _maxSize)
            {
                _maxSize = size
            }
        }
    }
    
    private func yMin(_ entry: BubbleChartDataEntry) -> Double
    {
        return entry.value
    }
    
    private func yMax(_ entry: BubbleChartDataEntry) -> Double
    {
        return entry.value
    }
    
    private func xMin(_ entry: BubbleChartDataEntry) -> Double
    {
        return Double(entry.xIndex)
    }
    
    private func xMax(_ entry: BubbleChartDataEntry) -> Double
    {
        return Double(entry.xIndex)
    }
    
    private func largestSize(_ entry: BubbleChartDataEntry) -> CGFloat
    {
        return entry.size
    }
    
    // MARK: - Styling functions and accessors
    
    /// Sets/gets the width of the circle that surrounds the bubble when highlighted
    open var highlightCircleWidth: CGFloat = 2.5
    
    // MARK: - NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RealmBubbleDataSet
        copy._xMin = _xMin
        copy._xMax = _xMax
        copy._maxSize = _maxSize
        copy.highlightCircleWidth = highlightCircleWidth
        return copy
    }
}
