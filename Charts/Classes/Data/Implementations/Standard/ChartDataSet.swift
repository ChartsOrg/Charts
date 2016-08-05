//
//  ChartDataSet.swift
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

/// Determines how to round DataSet index values for `ChartDataSet.entryIndex(x, rounding)` when an exact x-pos is not found.
@objc
public enum ChartDataSetRounding: Int
{
    case Up = 0
    case Down = 1
    case Closest = 2
}

/// The DataSet class represents one group or type of entries (Entry) in the Chart that belong together.
/// It is designed to logically separate different groups of values inside the Chart (e.g. the values for a specific line in the LineChart, or the values of a specific group of bars in the BarChart).
public class ChartDataSet: ChartBaseDataSet
{
    public required init()
    {
        super.init()
        
        _values = [ChartDataEntry]()
    }
    
    public override init(label: String?)
    {
        super.init(label: label)
        
        _values = [ChartDataEntry]()
    }
    
    public init(values: [ChartDataEntry]?, label: String?)
    {
        super.init(label: label)
        
        _values = values == nil ? [ChartDataEntry]() : values
        
        self.calcMinMax()
    }
    
    public convenience init(values: [ChartDataEntry]?)
    {
        self.init(values: values, label: "DataSet")
    }
    
    // MARK: - Data functions and accessors
    
    /// the entries that this dataset represents / holds together
    internal var _values: [ChartDataEntry]!
    
    /// maximum y-value in the value array
    internal var _yMax: Double = -DBL_MAX
    
    /// minimum y-value in the value array
    internal var _yMin: Double = DBL_MAX
    
    /// maximum x-value in the value array
    internal var _xMax: Double = -DBL_MAX
    
    /// minimum x-value in the value array
    internal var _xMin: Double = DBL_MAX
    
    /// *
    /// - note: Calls `notifyDataSetChanged()` after setting a new value.
    /// - returns: The array of y-values that this DataSet represents.
    public var values: [ChartDataEntry]
    {
        get
        {
            return _values
        }
        set
        {
            _values = newValue
            notifyDataSetChanged()
        }
    }
    
    /// Use this method to tell the data set that the underlying data has changed
    public override func notifyDataSetChanged()
    {
        calcMinMax()
    }
    
    public override func calcMinMax()
    {
        if _values.count == 0
        {
            return
        }
        
        _yMax = -DBL_MAX
        _yMin = DBL_MAX
        _xMax = -DBL_MAX
        _xMin = DBL_MAX
        
        for e in _values
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
    
    /// - returns: the minimum y-value this DataSet holds
    public override var yMin: Double { return _yMin }
    
    /// - returns: the maximum y-value this DataSet holds
    public override var yMax: Double { return _yMax }
    
    /// - returns: the minimum x-value this DataSet holds
    public override var xMin: Double { return _xMin }
    
    /// - returns: the maximum x-value this DataSet holds
    public override var xMax: Double { return _xMax }
    
    /// - returns: the number of y-values this DataSet represents
    public override var entryCount: Int { return _values?.count ?? 0 }
    
    /// - returns: the value of the Entry object at the given xIndex. Returns NaN if no value is at the given x-index.
    public override func yValueForXValue(x: Double) -> Double
    {
        let e = self.entryForXPos(x)
        
        if (e !== nil && e!.x == x) { return e!.y }
        else { return Double.NaN }
    }
    
    /// - returns: all of the y values of the Entry objects at the given xIndex. Returns NaN if no value is at the given x-index.
    public override func yValuesForXValue(x: Double) -> [Double]
    {
        let entries = self.entriesForXPos(x)
        
        var yVals = [Double]()
        for e in entries
        {
            yVals.append(e.y)
        }
        
        return yVals
    }
    
    /// - returns: the entry object found at the given index (not x-value!)
    /// - throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    public override func entryForIndex(i: Int) -> ChartDataEntry?
    {
        return _values[i]
    }
    
    /// - returns: the first Entry object found at the given x-pos with binary search.
    /// If the no Entry at the specifed x-pos is found, this method returns the Entry at the closest x-pox.
    /// nil if no Entry object at that x-pos.
    /// - parameter x: the x-pos
    /// - parameter rounding: determine whether to round up/down/closest if there is no Entry matching the provided x-pos
    public override func entryForXPos(x: Double, rounding: ChartDataSetRounding) -> ChartDataEntry?
    {
        let index = self.entryIndex(x: x, rounding: rounding)
        if (index > -1)
        {
            return _values[index]
        }
        return nil
    }
    
    /// - returns: the first Entry object found at the given x-pos with binary search.
    /// If the no Entry at the specifed x-pos is found, this method returns the Entry at the closest x-pos.
    /// nil if no Entry object at that x-pos.
    public override func entryForXPos(x: Double) -> ChartDataEntry?
    {
        return entryForXPos(x, rounding: .Closest)
    }
    
    /// - returns: all Entry objects found at the given xIndex with binary search.
    /// An empty array if no Entry object at that index.
    public override func entriesForXPos(x: Double) -> [ChartDataEntry]
    {
        var entries = [ChartDataEntry]()
        
        var low = 0
        var high = _values.count - 1
        
        while low <= high
        {
            var m = (high + low) / 2
            var entry = _values[m]
            
            if x == entry.x
            {
                while m > 0 && _values[m - 1].x == x
                {
                    m -= 1
                }
                
                high = _values.count
                while m < high
                {
                    entry = _values[m]
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
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter x: x-index of the entry to search for
    /// - parameter rounding: x-index of the entry to search for
    public override func entryIndex(x x: Double, rounding: ChartDataSetRounding) -> Int
    {
        var low = 0
        var high = _values.count - 1
        var closest = -1
        
        while low <= high
        {
            var m = (high + low) / 2
            let entry = _values[m]
            
            if x == entry.x
            {
                while m > 0 && _values[m - 1].x == x
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
                let closestXIndex = _values[closest].x
                if closestXIndex < x && closest < _values.count - 1
                {
                    closest = closest + 1
                }
            }
            else if rounding == .Down
            {
                let closestXIndex = _values[closest].x
                if closestXIndex > x && closest > 0
                {
                    closest = closest - 1
                }
            }
        }
        
        return closest
    }
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter e: the entry to search for
    public override func entryIndex(entry e: ChartDataEntry) -> Int
    {
        for i in 0 ..< _values.count
        {
            if _values[i] === e
            {
                return i
            }
        }
        
        return -1
    }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to the end of the list.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    /// - returns: true
    public override func addEntry(e: ChartDataEntry) -> Bool
    {
        if (_values == nil)
        {
            _values = [ChartDataEntry]()
        }
        
        calcMinMax(entry: e)
        
        _values.append(e)
        
        return true
    }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to their appropriate index respective to it's x-index.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    /// - returns: true
    public override func addEntryOrdered(e: ChartDataEntry) -> Bool
    {
        if (_values == nil)
        {
            _values = [ChartDataEntry]()
        }
        
        calcMinMax(entry: e)
        
        if _values.last?.x > e.x
        {
            var closestIndex = entryIndex(x: e.x, rounding: .Up)
            while _values[closestIndex].x < e.x
            {
                closestIndex += 1
            }
            _values.insert(e, atIndex: closestIndex)
        }
        else
        {
            _values.append(e)
        }
        
        return true
    }
    
    /// Removes an Entry from the DataSet dynamically.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter entry: the entry to remove
    /// - returns: true if the entry was removed successfully, else if the entry does not exist
    public override func removeEntry(entry: ChartDataEntry) -> Bool
    {
        var removed = false
        
        for i in 0 ..< _values.count
        {
            if (_values[i] === entry)
            {
                _values.removeAtIndex(i)
                removed = true
                break
            }
        }
        
        if (removed)
        {
            calcMinMax()
        }
        
        return removed
    }
    
    /// Removes the first Entry (at index 0) of this DataSet from the entries array.
    ///
    /// - returns: true if successful, false if not.
    public override func removeFirst() -> Bool
    {
        let entry: ChartDataEntry? = _values.isEmpty ? nil : _values.removeFirst()
        
        let removed = entry != nil
        
        if (removed)
        {
            calcMinMax()
        }
        
        return removed;
    }
    
    /// Removes the last Entry (at index size-1) of this DataSet from the entries array.
    ///
    /// - returns: true if successful, false if not.
    public override func removeLast() -> Bool
    {
        let entry: ChartDataEntry? = _values.isEmpty ? nil : _values.removeLast()
        
        let removed = entry != nil
        
        if (removed)
        {
            calcMinMax()
        }
        
        return removed;
    }
    
    /// Checks if this DataSet contains the specified Entry.
    /// - returns: true if contains the entry, false if not.
    public override func contains(e: ChartDataEntry) -> Bool
    {
        for entry in _values
        {
            if (entry.isEqual(e))
            {
                return true
            }
        }
        
        return false
    }
    
    /// Removes all values from this DataSet and recalculates min and max value.
    public override func clear()
    {
        _values.removeAll(keepCapacity: true)
        notifyDataSetChanged()
    }
    
    // MARK: - Data functions and accessors

    // MARK: - NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! ChartDataSet
        
        copy._values = _values
        copy._yMax = _yMax
        copy._yMin = _yMin

        return copy
    }
}


