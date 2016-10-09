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
#if NEEDS_CHARTS
import Charts
#endif
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
    
    public init(results: RLMResults<RLMObject>?, xValueField: String?, yValueField: String, label: String?)
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
            _results = _results?.sortedResults(usingProperty: _xValueField!, ascending: true)
        }
        
        notifyDataSetChanged()
        
        initialize()
    }
    
    public convenience init(results: RLMResults<RLMObject>?, yValueField: String, label: String?)
    {
        self.init(results: results, xValueField: nil, yValueField: yValueField, label: label)
    }
    
    public convenience init(results: RLMResults<RLMObject>?, xValueField: String?, yValueField: String)
    {
        self.init(results: results, xValueField: xValueField, yValueField: yValueField, label: "DataSet")
    }
    
    public convenience init(results: RLMResults<RLMObject>?, yValueField: String)
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
            _results = realm.objects(modelName, with: predicate!)
        }
        
        if _xValueField != nil
        {
            _results = _results?.sortedResults(usingProperty: _xValueField!, ascending: true)
        }
    
        notifyDataSetChanged()
    }
    
    // MARK: - Data functions and accessors
    
    internal var _results: RLMResults<RLMObject>?
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
        
        let iterator = NSFastEnumerationIterator(results)
        while let e = iterator.next()
        {
            _cache.append(buildEntryFromResultObject(e as! RLMObject, x: xValue))
            xValue += 1.0
        }
    }
    
    internal func buildEntryFromResultObject(_ object: RLMObject, x: Double) -> ChartDataEntry
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
    open override func notifyDataSetChanged()
    {
        buildCache()
        calcMinMax()
    }
    
    open override func calcMinMax()
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
    open override var yMin: Double { return _yMin }
    
    /// - returns: The maximum y-value this DataSet holds
    open override var yMax: Double { return _yMax }
    
    /// - returns: The minimum x-value this DataSet holds
    open override var xMin: Double { return _xMin }
    
    /// - returns: The maximum x-value this DataSet holds
    open override var xMax: Double { return _xMax }
    
    /// - returns: The number of y-values this DataSet represents
    open override var entryCount: Int { return Int(_results?.count ?? 0) }
    
    /// - returns: The entry object found at the given index (not x-value!)
    /// - throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    open override func entryForIndex(_ i: Int) -> ChartDataEntry?
    {
        if _cache.count == 0
        {
            buildCache()
        }
        return _cache[i]
    }
    
    /// - returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value according to the rounding.
    /// nil if no Entry object at that x-value.
    /// - parameter xValue: the x-value
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    /// - parameter rounding: determine whether to round up/down/closest if there is no Entry matching the provided x-value
    open override func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding) -> ChartDataEntry?
    {
        let index = self.entryIndex(x: xValue, closestToY: yValue, rounding: rounding)
        if index > -1
        {
            return entryForIndex(index)
        }
        return nil
    }
    
    /// - returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value.
    /// nil if no Entry object at that x-value.
    /// - parameter xValue: the x-value
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    open override func entryForXValue(
        _ xValue: Double,
        closestToY y: Double) -> ChartDataEntry?
    {
        return entryForXValue(xValue, closestToY: y, rounding: .closest)
    }
    
    /// - returns: All Entry objects found at the given x-value with binary search.
    /// An empty array if no Entry object at that x-value.
    open override func entriesForXValue(_ xValue: Double) -> [ChartDataEntry]
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
            
            if xValue == entry.x
            {
                while m > 0 && _cache[m - 1].x == xValue
                {
                    m -= 1
                }
                
                high = _cache.count
                while m < high
                {
                    entry = _cache[m]
                    if entry.x == xValue
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
                if xValue > entry.x
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
    
    /// - returns: The array-index of the specified entry.
    /// If the no Entry at the specified x-value is found, this method returns the index of the Entry at the closest x-value according to the rounding.
    ///
    /// - parameter xValue: x-value of the entry to search for
    /// - parameter closestToY: If there are multiple y-values for the specified x-value,
    /// - parameter rounding: Rounding method if exact value was not found
    open override func entryIndex(
        x xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding) -> Int
    {
        /*guard let results = _results else { return -1 }
        
        let foundIndex = results.indexOfObjectWithPredicate(
            NSPredicate(format: "%K == %f", _xValueField!, x)
        )
        
        // TODO: Figure out a way to quickly find the closest index
        
        return Int(foundIndex)*/
        
        var low = 0
        var high = _cache.count - 1
        var closest = high
        
        while low < high
        {
            let m = (low + high) / 2
            
            let d1 = _cache[m].x - xValue
            let d2 = _cache[m + 1].x - xValue
            let ad1 = abs(d1), ad2 = abs(d2)
            
            if ad2 < ad1
            {
                // [m + 1] is closer to xValue
                // Search in an higher place
                low = m + 1
            }
            else if ad1 < ad2
            {
                // [m] is closer to xValue
                // Search in a lower place
                high = m
            }
            else
            {
                // We have multiple sequential x-value with same distance
                
                if d1 >= 0.0
                {
                    // Search in a lower place
                    high = m
                }
                else if d1 < 0.0
                {
                    // Search in an higher place
                    low = m + 1
                }
            }
            
            closest = high
        }
        
        if closest != -1
        {
            let closestXValue = _cache[closest].x
            
            if rounding == .up
            {
                // If rounding up, and found x-value is lower than specified x, and we can go upper...
                if closestXValue < xValue && closest < _cache.count - 1
                {
                    closest += 1
                }
            }
            else if rounding == .down
            {
                // If rounding down, and found x-value is upper than specified x, and we can go lower...
                if closestXValue > xValue && closest > 0
                {
                    closest -= 1
                }
            }
            
            // Search by closest to y-value
            if !yValue.isNaN
            {
                while closest > 0 && _cache[closest - 1].x == closestXValue
                {
                    closest -= 1
                }
                
                var closestYValue = _cache[closest].y
                var closestYIndex = closest
                
                while true
                {
                    closest += 1
                    if closest >= _cache.count { break }
                    
                    let value = _cache[closest]
                    
                    if value.x != closestXValue { break }
                    if abs(value.y - yValue) < abs(closestYValue - yValue)
                    {
                        closestYValue = yValue
                        closestYIndex = closest
                    }
                }
                
                closest = closestYIndex
            }
        }
        
        return closest
    }
    
    /// - returns: The array-index of the specified entry
    ///
    /// - parameter e: the entry to search for
    open override func entryIndex(entry e: ChartDataEntry) -> Int
    {
        for i in 0 ..< _cache.count
        {
            if _cache[i] === e || _cache[i].isEqual(e)
            {
                return i
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
    /// - returns: `true` if contains the entry, `false` ifnot.
    open override func contains(_ e: ChartDataEntry) -> Bool
    {
        for entry in _cache
        {
            if entry.isEqual(e)
            {
                return true
            }
        }
        
        return false
    }
    
    /// - returns: The fieldname that represents the "y-values" in the realm-data.
    open var yValueField: String?
    {
        get
        {
            return _yValueField
        }
    }
    
    /// - returns: The fieldname that represents the "x-values" in the realm-data.
    open var xValueField: String?
    {
        get
        {
            return _xValueField
        }
    }
    
    // MARK: - NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
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


