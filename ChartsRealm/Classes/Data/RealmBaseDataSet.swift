//
//  RealmBaseDataSet.swift
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

import Charts
import Realm
import Realm.Dynamic

open class RealmBaseDataSet: ChartBaseDataSet
{
    open func initialize()
    {
        fatalError("RealmBaseDataSet is an abstract class, you must inherit from it. Also please do not call super.initialize().")
    }
    
    public required init()
    {
        super.init()
        
        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        
        initialize()
    }
    
    public override init(label: String?)
    {
        super.init()
        
        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        
        self.label = label
        
        initialize()
    }
    
    public init(results: RLMResults<RLMObject>?, yValueField: String, xIndexField: String?, label: String?)
    {
        super.init()
        
        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        
        self.label = label
        
        _results = results
        _yValueField = yValueField
        _xIndexField = xIndexField
        _results = _results?.sortedResults(usingProperty: _xIndexField!, ascending: true)
        
        notifyDataSetChanged()
        
        initialize()
    }
    
    public convenience init(results: RLMResults<RLMObject>?, yValueField: String, label: String?)
    {
        self.init(results: results, yValueField: yValueField, xIndexField: nil, label: label)
    }
    
    public convenience init(results: RLMResults<RLMObject>?, yValueField: String, xIndexField: String?)
    {
        self.init(results: results, yValueField: yValueField, xIndexField: xIndexField, label: "DataSet")
    }
    
    public convenience init(results: RLMResults<RLMObject>?, yValueField: String)
    {
        self.init(results: results, yValueField: yValueField)
    }
    
    public init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, xIndexField: String?, label: String?)
    {
        super.init()
        
        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        
        self.label = label
        
        _yValueField = yValueField
        _xIndexField = xIndexField
        
        if realm != nil
        {
            loadResults(realm: realm!, modelName: modelName)
        }
        
        initialize()
    }
    
    public convenience init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, label: String?)
    {
        self.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, yValueField: yValueField, xIndexField: nil, label: label)
    }
    
    open func loadResults(realm: RLMRealm, modelName: String)
    {
        loadResults(realm: realm, modelName: modelName, predicate: nil)
    }
    
    open func loadResults(realm: RLMRealm, modelName: String, predicate: NSPredicate?)
    {
        if predicate == nil
        {
            _results = realm.allObjects(modelName)
        }
        else
        {
            _results = realm.objects(modelName, with: predicate)
        }
        
        if _xIndexField != nil
        {
            _results = _results?.sortedResults(usingProperty: _xIndexField!, ascending: true)
        }
    
        notifyDataSetChanged()
    }
    
    // MARK: - Data functions and accessors
    
    internal var _results: RLMResults<RLMObject>?
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
    internal func ensureCache(start: Int, end: Int)
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
            
            for i in UInt(start) ..< UInt(end + 1)
            {
                _cache.append(buildEntryFromResultObject(results.object(at: i), atIndex: i))
            }
            
            _cacheFirst = start
            _cacheLast = end
        }
        
        if start < _cacheFirst
        {
            var newEntries = [ChartDataEntry]()
            newEntries.reserveCapacity(start - _cacheFirst)
            
            for i in UInt(start) ..< UInt(_cacheFirst)
            {
                newEntries.append(buildEntryFromResultObject(results.object(at: i), atIndex: i))
            }
            
            _cache.insert(contentsOf: newEntries, at: 0)
            
            _cacheFirst = start
        }
        
        if end > _cacheLast
        {
            for i in UInt(_cacheLast + 1) ..< UInt(end + 1)
            {
                _cache.append(buildEntryFromResultObject(results.object(at: i), atIndex: i))
            }
            
            _cacheLast = end
        }
    }
    
    internal func buildEntryFromResultObject(_ object: RLMObject, atIndex: UInt) -> ChartDataEntry
    {
        let entry = ChartDataEntry(value: object[_yValueField!] as! Double, xIndex: _xIndexField == nil ? Int(atIndex) : object[_xIndexField!] as! Int)
        
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
    open override func notifyDataSetChanged()
    {
        calcMinMax(start: _lastStart, end: _lastEnd)
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
        _lastEnd = endValue
        
        _yMin = DBL_MAX
        _yMax = -DBL_MAX
        
        for i in stride(from: start, through: endValue, by: 1)
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
    open override var yMin: Double { return _yMin }
    
    /// - returns: the maximum y-value this DataSet holds
    open override var yMax: Double { return _yMax }
    
    /// - returns: the number of y-values this DataSet represents
    open override var entryCount: Int { return Int(_results?.count ?? 0) }
    
    /// - returns: the value of the Entry object at the given xIndex. Returns NaN if no value is at the given x-index.
    open override func yValForXIndex(_ x: Int) -> Double
    {
        let e = self.entryForXIndex(x)
        
        if (e !== nil && e!.xIndex == x) { return e!.value }
        else { return Double.nan }
    }
    
    /// - returns: all of the y values of the Entry objects at the given xIndex. Returns NaN if no value is at the given x-index.
    open override func yValsForXIndex(_ x: Int) -> [Double]
    {
        let entries = self.entriesForXIndex(x)
        
        var yVals = [Double]()
        for e in entries
        {
            yVals.append(e.value)
        }
        
        return yVals
    }
    
    /// - returns: the entry object found at the given index (not x-index!)
    /// - throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    open override func entryForIndex(_ i: Int) -> ChartDataEntry?
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
    open override func entryForXIndex(_ x: Int, rounding: ChartDataSetRounding) -> ChartDataEntry?
    {
        let index = self.entryIndex(xIndex: x, rounding: rounding)
        if (index > -1)
        {
            return entryForIndex(index)
        }
        return nil
    }
    
    /// - returns: the first Entry object found at the given xIndex with binary search.
    /// If the no Entry at the specifed x-index is found, this method returns the Entry at the closest x-index.
    /// nil if no Entry object at that index.
    open override func entryForXIndex(_ x: Int) -> ChartDataEntry?
    {
        return entryForXIndex(x, rounding: .closest)
    }
    
    /// - returns: all Entry objects found at the given xIndex with binary search.
    /// An empty array if no Entry object at that index.
    open override func entriesForXIndex(_ x: Int) -> [ChartDataEntry]
    {
        var entries = [ChartDataEntry]()
        
        guard let results = _results else { return entries }
        
        if _xIndexField == nil
        {
            if results.count > UInt(x)
            {
                entries.append(buildEntryFromResultObject(results.object(at: UInt(x)), atIndex: UInt(x)))
            }
        }
        else
        {
            let foundObjects = results.objects(
                with: NSPredicate(format: "%K == %d", _xIndexField!, x)
            )
            
            for e in foundObjects
            {
                entries.append(buildEntryFromResultObject(e as! RLMObject, atIndex: UInt(x)))
            }
        }
        
        return entries
    }
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter x: x-index of the entry to search for
    open override func entryIndex(xIndex x: Int, rounding: ChartDataSetRounding) -> Int
    {
        guard let results = _results else { return -1 }
        
        let foundIndex = results.indexOfObject(
            with: NSPredicate(format: "%K == %d", _xIndexField!, x)
        )
        
        // TODO: Figure out a way to quickly find the closest index
        
        return Int(foundIndex)
    }
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter e: the entry to search for
    open override func entryIndex(entry e: ChartDataEntry) -> Int
    {
        for i in 0 ..< _cache.count
        {
            if (_cache[i] === e || _cache[i].isEqual(e))
            {
                return _cacheFirst + i
            }
        }
        
        return -1
    }
    
    /// Not supported on Realm datasets
    open override func addEntry(_ e: ChartDataEntry) -> Bool
    {
        return false
    }
    
    /// Not supported on Realm datasets
    open override func addEntryOrdered(_ e: ChartDataEntry) -> Bool
    {
        return false
    }
    
    /// Not supported on Realm datasets
    open override func removeEntry(_ entry: ChartDataEntry) -> Bool
    {
        return false
    }
    
    /// Checks if this DataSet contains the specified Entry.
    /// - returns: true if contains the entry, false if not.
    open override func contains(_ e: ChartDataEntry) -> Bool
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
    
    /// Returns the fieldname that represents the "y-values" in the realm-data.
    open var yValueField: String?
    {
        get
        {
            return _yValueField
        }
    }
    
    /// Returns the fieldname that represents the "x-index" in the realm-data.
    open var xIndexField: String?
    {
        get
        {
            return _xIndexField
        }
    }
    
    // MARK: - NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> Any
    {
        let copy = super.copyWithZone(zone) as! RealmBaseDataSet
        
        copy._results = _results
        copy._yValueField = _yValueField
        copy._xIndexField = _xIndexField
        copy._yMax = _yMax
        copy._yMin = _yMin
        copy._lastStart = _lastStart
        copy._lastEnd = _lastEnd
        
        return copy
    }
}


