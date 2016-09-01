//
//  RealmBaseDataSet.swift
//  Charts
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

public class RealmBaseDataSet: ChartBaseDataSet
{
    public func initialize()
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
    
    public init(results: RLMResults?, xValueField: String?, yValueField: String, label: String?)
    {
        super.init()
        
        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        
        self.label = label
        
        _results = results
        _yValueField = yValueField
        _xValueField = xValueField
        
        if _xValueField != nil
        {
            _results = _results?.sortedResultsUsingProperty(_xValueField!, ascending: true)
        }
        
        notifyDataSetChanged()
        
        initialize()
    }
    
    public convenience init(results: RLMResults?, yValueField: String, label: String?)
    {
        self.init(results: results, xValueField: nil, yValueField: yValueField, label: label)
    }
    
    public convenience init(results: RLMResults?, xValueField: String?, yValueField: String)
    {
        self.init(results: results, xValueField: xValueField, yValueField: yValueField, label: "DataSet")
    }
    
    public convenience init(results: RLMResults?, yValueField: String)
    {
        self.init(results: results, yValueField: yValueField)
    }
    
    public init(realm: RLMRealm?, modelName: String, resultsWhere: String, xValueField: String?, yValueField: String, label: String?)
    {
        super.init()
        
        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        
        self.label = label
        
        _yValueField = yValueField
        _xValueField = xValueField
        
        if realm != nil
        {
            loadResults(realm: realm!, modelName: modelName)
        }
        
        initialize()
    }
    
    public convenience init(realm: RLMRealm?, modelName: String, resultsWhere: String, yValueField: String, label: String?)
    {
        self.init(realm: realm, modelName: modelName, resultsWhere: resultsWhere, xValueField: nil, yValueField: yValueField, label: label)
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
        
        if _xValueField != nil
        {
            _results = _results?.sortedResultsUsingProperty(_xValueField!, ascending: true)
        }
    
        notifyDataSetChanged()
    }
    
    // MARK: - Data functions and accessors
    
    internal var _results: RLMResults?
    internal var _yValueField: String?
    internal var _xValueField: String?
    internal var _cache = [ChartDataEntry]()
    
    internal var _yMax: Double = -DBL_MAX
    internal var _yMin: Double = DBL_MAX
    
    internal var _xMax: Double = -DBL_MAX
    internal var _xMin: Double = DBL_MAX
    
    /// Makes sure that the cache is populated for the specified range
    internal func buildCache()
    {
        guard let results = _results else { return }
        
        _cache.removeAll()
        _cache.reserveCapacity(Int(results.count))
        
        var xValue: Double = 0.0
        for e in results
        {
            _cache.append(buildEntryFromResultObject(e as! RLMObject, x: xValue))
            xValue += 1.0
        }
    }
    
    internal func buildEntryFromResultObject(object: RLMObject, x: Double) -> ChartDataEntry
    {
        let entry = ChartDataEntry(x: _xValueField == nil ? x : object[_xValueField!] as! Double, y: object[_yValueField!] as! Double)
        
        return entry
    }
    
    /// Makes sure that the cache is populated for the specified range
    internal func clearCache()
    {
        _cache.removeAll()
    }
    
    /// Use this method to tell the data set that the underlying data has changed
    public override func notifyDataSetChanged()
    {
        buildCache()
        calcMinMax()
    }
    
    public override func calcMinMax()
    {
        if _cache.count == 0
        {
            return
        }
        
        _yMax = -DBL_MAX
        _yMin = DBL_MAX
        _xMax = -DBL_MAX
        _xMin = DBL_MAX
        
        for e in _cache
        {
            calcMinMax(entry: e)
        }
    }
    
     /// Updates the min and max x and y value of this DataSet based on the given Entry.
     ///
     /// - parameter e:
    internal func calcMinMax(entry e: ChartDataEntry)
    {
        if e.y < _yMin
        {
            _yMin = e.y
        }
        if e.y > _yMax
        {
            _yMax = e.y
        }
        if e.x < _xMin
        {
            _xMin = e.x
        }
        if e.x > _xMax
        {
            _xMax = e.x
        }
    }

    /// - returns: The minimum y-value this DataSet holds
    public override var yMin: Double { return _yMin }
    
    /// - returns: The maximum y-value this DataSet holds
    public override var yMax: Double { return _yMax }
    
    /// - returns: The minimum x-value this DataSet holds
    public override var xMin: Double { return _xMin }
    
    /// - returns: The maximum x-value this DataSet holds
    public override var xMax: Double { return _xMax }
    
    /// - returns: The number of y-values this DataSet represents
    public override var entryCount: Int { return Int(_results?.count ?? 0) }
    
    /// - returns: The entry object found at the given index (not x-value!)
    /// - throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    public override func entryForIndex(i: Int) -> ChartDataEntry?
    {
        if _cache.count == 0
        {
            buildCache()
        }
        return _cache[i]
    }
    
    /// - returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specifed x-value is found, this method returns the Entry at the closest x-value.
    /// nil if no Entry object at that x-value.
    /// - parameter x: the x-value
    /// - parameter rounding: determine whether to round up/down/closest if there is no Entry matching the provided x-value
    public override func entryForXValue(x: Double, rounding: ChartDataSetRounding) -> ChartDataEntry?
    {
        let index = self.entryIndex(x: x, rounding: rounding)
        if (index > -1)
        {
            return entryForIndex(index)
        }
        return nil
    }
    
    /// - returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specifed x-value is found, this method returns the Entry at the closest x-value.
    /// nil if no Entry object at that x-value.
    public override func entryForXValue(x: Double) -> ChartDataEntry?
    {
        return entryForXValue(x, rounding: .Closest)
    }
    
    /// - returns: All Entry objects found at the given x-value with binary search.
    /// An empty array if no Entry object at that x-value.
    public override func entriesForXValue(x: Double) -> [ChartDataEntry]
    {
        /*var entries = [ChartDataEntry]()
        
        guard let results = _results else { return entries }
        
        if _xValueField != nil
        {
            let foundObjects = results.objectsWithPredicate(
                NSPredicate(format: "%K == %f", _xValueField!, x)
            )
            
            for e in foundObjects
            {
                entries.append(buildEntryFromResultObject(e as! RLMObject, x: x))
            }
        }
        
        return entries*/
        
        var entries = [ChartDataEntry]()
        
        var low = 0
        var high = _cache.count - 1
        
        while low <= high
        {
            var m = (high + low) / 2
            var entry = _cache[m]
            
            if x == entry.x
            {
                while m > 0 && _cache[m - 1].x == x
                {
                    m -= 1
                }
                
                high = _cache.count
                while m < high
                {
                    entry = _cache[m]
                    if entry.x == x
                    {
                        entries.append(entry)
                    }
                    else
                    {
                        break
                    }
                    
                    m += 1
                }
                
                break
            }
            else
            {
                if x > entry.x
                {
                    low = m + 1
                }
                else
                {
                    high = m - 1
                }
            }
        }
        
        return entries
    }
    
    /// - returns: The array-index of the specified entry
    ///
    /// - parameter x: x-value of the entry to search for
    public override func entryIndex(x x: Double, rounding: ChartDataSetRounding) -> Int
    {
        /*guard let results = _results else { return -1 }
        
        let foundIndex = results.indexOfObjectWithPredicate(
            NSPredicate(format: "%K == %f", _xValueField!, x)
        )
        
        // TODO: Figure out a way to quickly find the closest index
        
        return Int(foundIndex)*/
        
        var low = 0
        var high = _cache.count - 1
        var closest = -1
        
        while low <= high
        {
            var m = (high + low) / 2
            let entry = _cache[m]
            
            if x == entry.x
            {
                while m > 0 && _cache[m - 1].x == x
                {
                    m -= 1
                }
                
                return m
            }
            
            if x > entry.x
            {
                low = m + 1
            }
            else
            {
                high = m - 1
            }
            
            closest = m
        }
        
        if closest != -1
        {
            if rounding == .Up
            {
                let closestXIndex = _cache[closest].x
                if closestXIndex < x && closest < _cache.count - 1
                {
                    closest = closest + 1
                }
            }
            else if rounding == .Down
            {
                let closestXIndex = _cache[closest].x
                if closestXIndex > x && closest > 0
                {
                    closest = closest - 1
                }
            }
        }
        
        return closest
    }
    
    /// - returns: The array-index of the specified entry
    ///
    /// - parameter e: the entry to search for
    public override func entryIndex(entry e: ChartDataEntry) -> Int
    {
        for i in 0 ..< _cache.count
        {
            if (_cache[i] === e || _cache[i].isEqual(e))
            {
                return i
            }
        }
        
        return -1
    }
    
    /// Not supported on Realm datasets
    public override func addEntry(e: ChartDataEntry) -> Bool
    {
        return false
    }
    
    /// Not supported on Realm datasets
    public override func addEntryOrdered(e: ChartDataEntry) -> Bool
    {
        return false
    }
    
    /// Not supported on Realm datasets
    public override func removeEntry(entry: ChartDataEntry) -> Bool
    {
        return false
    }
    
    /// Checks if this DataSet contains the specified Entry.
    /// - returns: `true` if contains the entry, `false` ifnot.
    public override func contains(e: ChartDataEntry) -> Bool
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
    
    /// - returns: The fieldname that represents the "y-values" in the realm-data.
    public var yValueField: String?
    {
        get
        {
            return _yValueField
        }
    }
    
    /// - returns: The fieldname that represents the "x-values" in the realm-data.
    public var xValueField: String?
    {
        get
        {
            return _xValueField
        }
    }
    
    // MARK: - NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! RealmBaseDataSet
        
        copy._results = _results
        copy._yValueField = _yValueField
        copy._xValueField = _xValueField
        copy._yMax = _yMax
        copy._yMin = _yMin
        copy._xMax = _xMax
        copy._xMin = _xMin
        
        return copy
    }
}


