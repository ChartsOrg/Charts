//
//  RealmDataSet.swift
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

public class RealmDataSet: NSObject, IChartDataSet
{
    public required override init()
    {
        super.init()
        
        // default color
        colors.append(UIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
    }
    
    public init(label: String?)
    {
        super.init()
        
        // default color
        colors.append(UIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        
        self.label = label
    }
    
    public init(results: RLMResults?, yValueField: String, xIndexField: String, label: String?)
    {
        super.init()
        
        // default color
        colors.append(UIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        
        self.label = label
        
        _results = results
        _yValueField = yValueField
        _xIndexField = xIndexField
        _results = _results?.sortedResultsUsingProperty(_xIndexField!, ascending: true)
        
        notifyDataSetChanged()
    }
    
    public convenience init(results: RLMResults?, yValueField: String, xIndexField: String)
    {
        self.init(results: results, yValueField: yValueField, xIndexField: xIndexField, label: "DataSet")
    }
    
    public init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, xIndexField: String, label: String?)
    {
        super.init()
        
        // default color
        colors.append(UIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        
        self.label = label
        
        _yValueField = yValueField
        _xIndexField = xIndexField
        
        if realm != nil
        {
            loadResults(realm: realm!, modelName: modelName)
        }
    }
    
    public func loadResults(realm realm: RLMRealm, modelName: String)
    {
        loadResults(realm: realm, modelName: modelName, predicate: nil)
    }
    
    public func loadResults(realm realm: RLMRealm, modelName: String, predicate: NSPredicate?)
    {
        if predicate == nil
        {
            _results = realm.allObjects(modelName)
        }
        else
        {
            _results = realm.objects(modelName, withPredicate: predicate)
        }
        
        _results = _results?.sortedResultsUsingProperty(_xIndexField!, ascending: true)
    
        notifyDataSetChanged()
    }
    
    // MARK: - Data functions and accessors
    
    internal var _results: RLMResults?
    internal var _yValueField: String?
    internal var _xIndexField: String?
    internal var _cache = [ChartDataEntry]()
    internal var _cacheFirst: Int = -1
    internal var _cacheLast: Int = -1
    
    internal var _yMax = Double(0.0)
    internal var _yMin = Double(0.0)
    
    /// the last start value used for calcMinMax
    internal var _lastStart: Int = 0
    
    /// the last end value used for calcMinMax
    internal var _lastEnd: Int = 0
    
    /// Makes sure that the cache is populated for the specified range
    internal func ensureCache(start start: Int, end: Int)
    {
        if start <= _cacheLast && end >= _cacheFirst
        {
            return
        }
        
        guard let results = _results else { return }
        
        if _cacheFirst == -1 || _cacheLast == -1
        {
            _cache.removeAll()
            _cache.reserveCapacity(end - start + 1)
            
            for (var i = UInt(start), max = UInt(end + 1); i < max; i++)
            {
                _cache.append(buildEntryFromResultObject(results.objectAtIndex(i)))
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
                newEntries.append(buildEntryFromResultObject(results.objectAtIndex(i)))
            }
            
            _cache.insertContentsOf(newEntries, at: 0)
            
            _cacheFirst = start
        }
        
        if end > _cacheLast
        {
            for (var i = UInt(_cacheLast + 1), max = UInt(end + 1); i < max; i++)
            {
                _cache.append(buildEntryFromResultObject(results.objectAtIndex(i)))
            }
            
            _cacheLast = end
        }
    }
    
    internal func buildEntryFromResultObject(object: RLMObject) -> ChartDataEntry
    {
        let entry = ChartDataEntry(value: object[_yValueField!] as! Double, xIndex: object[_xIndexField!] as! Int)
        
        return entry
    }
    
    /// Makes sure that the cache is populated for the specified range
    internal func clearCache()
    {
        _cache.removeAll()
        _cacheFirst = -1
        _cacheLast = -1
    }
    
    /// Use this method to tell the data set that the underlying data has changed
    public func notifyDataSetChanged()
    {
        calcMinMax(start: _lastStart, end: _lastEnd)
    }
    
    public func calcMinMax(start start: Int, end: Int)
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
            let e = _cache[i - _cacheFirst]
            
            if (!e.value.isNaN)
            {
                if (e.value < _yMin)
                {
                    _yMin = e.value
                }
                if (e.value > _yMax)
                {
                    _yMax = e.value
                }
            }
        }
        
        if (_yMin == DBL_MAX)
        {
            _yMin = 0.0
            _yMax = 0.0
        }
    }
    
    /// - returns: the minimum y-value this DataSet holds
    public var yMin: Double { return _yMin }
    
    /// - returns: the maximum y-value this DataSet holds
    public var yMax: Double { return _yMax }
    
    /// - returns: the number of y-values this DataSet represents
    public var entryCount: Int { return Int(_results?.count ?? 0) }
    
    /// - returns: the value of the Entry object at the given xIndex. Returns NaN if no value is at the given x-index.
    public func yValForXIndex(x: Int) -> Double
    {
        let e = self.entryForXIndex(x)
        
        if (e !== nil && e!.xIndex == x) { return e!.value }
        else { return Double.NaN }
    }
    
    /// - returns: the entry object found at the given index (not x-index!)
    /// - throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    public func entryForIndex(i: Int) -> ChartDataEntry?
    {
        if i < _lastStart || i > _lastEnd
        {
            ensureCache(start: i, end: i)
        }
        return _cache[i - _lastStart]
    }
    
    /// - returns: the first Entry object found at the given xIndex with binary search.
    /// If the no Entry at the specifed x-index is found, this method returns the Entry at the closest x-index.
    /// nil if no Entry object at that index.
    public func entryForXIndex(x: Int) -> ChartDataEntry?
    {
        let index = self.entryIndex(xIndex: x)
        if (index > -1)
        {
            return entryForIndex(index)
        }
        return nil
    }
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter x: x-index of the entry to search for
    public func entryIndex(xIndex x: Int) -> Int
    {
        guard let results = _results else { return -1 }
        
        let foundIndex = results.indexOfObjectWithPredicate(
            NSPredicate(format: "%K == %d", _xIndexField!, x)
        )
        
        if UInt(NSNotFound) == foundIndex
        {
            return -1
        }
        
        return Int(foundIndex)
    }
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter e: the entry to search for
    public func entryIndex(entry e: ChartDataEntry) -> Int
    {
        for (var i = 0; i < _cache.count; i++)
        {
            if (_cache[i] === e || _cache[i].isEqual(e))
            {
                return _cacheFirst + i
            }
        }
        
        return -1
    }
    
    /// Not supported on Realm datasets
    public func addEntry(e: ChartDataEntry) -> Bool
    {
        return false
    }
    
    /// Not supported on Realm datasets
    public func removeEntry(entry: ChartDataEntry) -> Bool
    {
        return false
    }
    
    /// Checks if this DataSet contains the specified Entry.
    /// - returns: true if contains the entry, false if not.
    public func contains(e: ChartDataEntry) -> Bool
    {
        for entry in _cache
        {
            if (entry.isEqual(e))
            {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Styling functions and accessors
    
    /// The label string that describes the DataSet.
    public var label: String? = "DataSet"
    
    /// The axis this DataSet should be plotted against.
    public var axisDependency = ChartYAxis.AxisDependency.Left
    
    /// All the colors that are set for this DataSet
    public var colors = [UIColor]()
    
    /// - returns: the color at the given index of the DataSet's color array.
    /// This prevents out-of-bounds by performing a modulus on the color index, so colours will repeat themselves.
    public func colorAt(var index: Int) -> UIColor
    {
        if (index < 0)
        {
            index = 0
        }
        return colors[index % colors.count]
    }
    
    public func resetColors()
    {
        colors.removeAll(keepCapacity: false)
    }
    
    public func addColor(color: UIColor)
    {
        colors.append(color)
    }
    
    public func setColor(color: UIColor)
    {
        colors.removeAll(keepCapacity: false)
        colors.append(color)
    }
    
    /// if true, value highlighting is enabled
    public var highlightEnabled = true
    
    /// - returns: true if value highlighting is enabled for this dataset
    public var isHighlightEnabled: Bool { return highlightEnabled }
    
    /// the formatter used to customly format the values
    internal var _valueFormatter: NSNumberFormatter? = ChartUtils.defaultValueFormatter()
    
    /// The formatter used to customly format the values
    public var valueFormatter: NSNumberFormatter?
    {
        get
        {
            return _valueFormatter
        }
        set
        {
            if newValue == nil
            {
                _valueFormatter = ChartUtils.defaultValueFormatter()
            }
            else
            {
                _valueFormatter = newValue
            }
        }
    }
    
    /// the color used for the value-text
    public var valueTextColor: UIColor = UIColor.blackColor()
    
    /// the font for the value-text labels
    public var valueFont: UIFont = UIFont.systemFontOfSize(7.0)
    
    /// Set this to true to draw y-values on the chart
    public var drawValuesEnabled = true
    
    /// Returns true if y-value drawing is enabled, false if not
    public var isDrawValuesEnabled: Bool
    {
        return drawValuesEnabled
    }
    
    /// Set the visibility of this DataSet. If not visible, the DataSet will not be drawn to the chart upon refreshing it.
    public var visible = true
    
    /// Returns true if this DataSet is visible inside the chart, or false if it is currently hidden.
    public var isVisible: Bool
    {
        return visible
    }
    
    // MARK: - NSObject
    
    public override var description: String
    {
        return String(format: "%@, label: %@, %i entries", arguments: [NSStringFromClass(self.dynamicType), self.label ?? "", self.entryCount])
    }
    
    public override var debugDescription: String
    {
        var desc = description + ":"
        
        for (var i = 0, count = self.entryCount; i < count; i++)
        {
            desc += "\n" + (self.entryForIndex(i)?.description ?? "")
        }
        
        return desc
    }
    
    // MARK: - NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = self.dynamicType.init()
        
        copy.colors = colors
        copy._results = _results
        copy._yValueField = _yValueField
        copy._xIndexField = _xIndexField
        copy._yMax = _yMax
        copy._yMin = _yMin
        copy._lastStart = _lastStart
        copy._lastEnd = _lastEnd
        copy.label = label
        
        return copy
    }
}


