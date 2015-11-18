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
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit
import Realm
import Realm.Dynamic

public class RealmBubbleDataSet: RealmBarLineScatterCandleBubbleDataSet, IBubbleChartDataSet
{
    public required init()
    {
        super.init()
    }
    
    public init(results: RLMResults?, yValueField: String, xIndexField: String, sizeField: String, label: String?)
    {
        _sizeField = sizeField
        
        super.init(results: results, yValueField: yValueField, xIndexField: xIndexField, label: label)
    }
    
    public convenience init(results: RLMResults?, yValueField: String, xIndexField: String, sizeField: String)
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
    
    public var xMin: Double { return _xMin }
    public var xMax: Double { return _xMax }
    public var maxSize: CGFloat { return _maxSize }
    
    /// Makes sure that the cache is populated for the specified range
    internal override func ensureCache(start start: Int, end: Int)
    {
        if start <= _cacheLast && end >= _cacheFirst
        {
            return
        }
        
        guard let yValueField = _yValueField,
            results = _results,
            sizeField = _sizeField,
            xIndexField = _xIndexField else { return }
        
        if _cacheFirst == -1 || _cacheLast == -1
        {
            _cache.removeAll()
            _cache.reserveCapacity(end - start + 1)
            
            for (var i = UInt(start), max = UInt(end + 1); i < max; i++)
            {
                let object = results.objectAtIndex(i)
                
                let entry = BubbleChartDataEntry(xIndex: object[xIndexField] as! Int, value: object[yValueField] as! Double, size: object[sizeField] as! CGFloat)
                _cache.append(entry)
            }
            
            _cacheFirst = start
            _cacheLast = end
        }
        
        if start < _cacheFirst
        {
            var newEntries = [ChartDataEntry]()
            newEntries.reserveCapacity(start - _cacheFirst)
            
            for (var i = UInt(start), max = UInt(_cacheFirst); i < max; i++)
            {
                let object = results.objectAtIndex(i)
                
                let entry = BubbleChartDataEntry(xIndex: object[xIndexField] as! Int, value: object[yValueField] as! Double, size: object[sizeField] as! CGFloat)
                newEntries.append(entry)
            }
            
            _cache.insertContentsOf(newEntries, at: 0)
            
            _cacheFirst = start
        }
        
        if end > _cacheLast
        {
            for (var i = UInt(_cacheLast + 1), max = UInt(end + 1); i < max; i++)
            {
                let object = results.objectAtIndex(i)
                
                let entry = BubbleChartDataEntry(xIndex: object[xIndexField] as! Int, value: object[yValueField] as! Double, size: object[sizeField] as! CGFloat)
                _cache.append(entry)
            }
            
            _cacheLast = end
        }
    }
    
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
        
        _yMin = yMin(_cache[start - _cacheFirst] as! BubbleChartDataEntry)
        _yMax = yMax(_cache[start - _cacheFirst] as! BubbleChartDataEntry)
        
        for (var i = start; i <= endValue; i++)
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
    
    private func yMin(entry: BubbleChartDataEntry) -> Double
    {
        return entry.value
    }
    
    private func yMax(entry: BubbleChartDataEntry) -> Double
    {
        return entry.value
    }
    
    private func xMin(entry: BubbleChartDataEntry) -> Double
    {
        return Double(entry.xIndex)
    }
    
    private func xMax(entry: BubbleChartDataEntry) -> Double
    {
        return Double(entry.xIndex)
    }
    
    private func largestSize(entry: BubbleChartDataEntry) -> CGFloat
    {
        return entry.size
    }
    
    // MARK: - Styling functions and accessors
    
    /// Sets/gets the width of the circle that surrounds the bubble when highlighted
    public var highlightCircleWidth: CGFloat = 2.5
    
    public func setColor(color: UIColor, alpha: CGFloat)
    {
        super.setColor(color.colorWithAlphaComponent(alpha))
    }
    
    // MARK: - NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RealmBubbleDataSet
        copy._xMin = _xMin
        copy._xMax = _xMax
        copy._maxSize = _maxSize
        copy.highlightCircleWidth = highlightCircleWidth
        return copy
    }
}