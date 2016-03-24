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
//  https://github.com/danielgindi/ios-charts
//

import Foundation

@objc
public enum ChartDataSetRounding: Int
{
    case Up = 0
    case Down = 1
    case Closest = 2
}

public class ChartDataSet: ChartBaseDataSet
{
    public required init()
    {
        super.init()
        
        _yVals = [ChartDataEntry]()
    }
    
    public override init(label: String?)
    {
        super.init(label: label)
        
        _yVals = [ChartDataEntry]()
    }
    
    public init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init(label: label)
        
        _yVals = yVals == nil ? [ChartDataEntry]() : yVals
        
        self.calcMinMax(start: _lastStart, end: _lastEnd)
    }
    
    public convenience init(yVals: [ChartDataEntry]?)
    {
        self.init(yVals: yVals, label: "DataSet")
    }
    
    // MARK: - Data functions and accessors
    
    internal var _yVals: [ChartDataEntry]!
    internal var _yMax = Double(0.0)
    internal var _yMin = Double(0.0)
    
    /// the last start value used for calcMinMax
    internal var _lastStart: Int = 0
    
    /// the last end value used for calcMinMax
    internal var _lastEnd: Int = 0
    
    public var yVals: [ChartDataEntry] { return _yVals }
    
    /// Use this method to tell the data set that the underlying data has changed
    public override func notifyDataSetChanged()
    {
        calcMinMax(start: _lastStart, end: _lastEnd)
    }
    
    public override func calcMinMax(start start: Int, end: Int)
    {
        let yValCount = _yVals.count
        
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
        
        _lastStart = start
        _lastEnd = endValue
        
        _yMin = DBL_MAX
        _yMax = -DBL_MAX
        
        for i in start ... endValue
        {
            let e = _yVals[i]
            
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
    public override var yMin: Double { return _yMin }
    
    /// - returns: the maximum y-value this DataSet holds
    public override var yMax: Double { return _yMax }
    
    /// - returns: the number of y-values this DataSet represents
    public override var entryCount: Int { return _yVals?.count ?? 0 }
    
    /// - returns: the value of the Entry object at the given xIndex. Returns NaN if no value is at the given x-index.
    public override func yValForXIndex(x: Int) -> Double
    {
        let e = self.entryForXIndex(x)
        
        if (e !== nil && e!.xIndex == x) { return e!.value }
        else { return Double.NaN }
    }
    
    /// - returns: the entry object found at the given index (not x-index!)
    /// - throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    public override func entryForIndex(i: Int) -> ChartDataEntry?
    {
        return _yVals[i]
    }
    
    /// - returns: the first Entry object found at the given xIndex with binary search.
    /// If the no Entry at the specifed x-index is found, this method returns the Entry at the closest x-index.
    /// nil if no Entry object at that index.
    public override func entryForXIndex(x: Int, rounding: ChartDataSetRounding) -> ChartDataEntry?
    {
        let index = self.entryIndex(xIndex: x, rounding: rounding)
        if (index > -1)
        {
            return _yVals[index]
        }
        return nil
    }
    
    /// - returns: the first Entry object found at the given xIndex with binary search.
    /// If the no Entry at the specifed x-index is found, this method returns the Entry at the closest x-index.
    /// nil if no Entry object at that index.
    public override func entryForXIndex(x: Int) -> ChartDataEntry?
    {
        return entryForXIndex(x, rounding: .Closest)
    }
    
    public func entriesForXIndex(x: Int) -> [ChartDataEntry]
    {
        var entries = [ChartDataEntry]()
        
        var low = 0
        var high = _yVals.count - 1
        
        while (low <= high)
        {
            var m = Int((high + low) / 2)
            var entry = _yVals[m]
            
            if (x == entry.xIndex)
            {
                while (m > 0 && _yVals[m - 1].xIndex == x)
                {
                    m -= 1
                }
                
                high = _yVals.count
                while (m < high)
                {
                    entry = _yVals[m]
                    if (entry.xIndex == x)
                    {
                        entries.append(entry)
                    }
                    else
                    {
                        break
                    }
                    
                    m += 1
                }
            }
            
            if (x > _yVals[m].xIndex)
            {
                low = m + 1
            }
            else
            {
                high = m - 1
            }
        }
        
        return entries
    }
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter x: x-index of the entry to search for
    /// - parameter rounding: x-index of the entry to search for
    public override func entryIndex(xIndex x: Int, rounding: ChartDataSetRounding) -> Int
    {
        var low = 0
        var high = _yVals.count - 1
        var closest = -1
        
        while (low <= high)
        {
            var m = (high + low) / 2
            let entry = _yVals[m]
            
            if (x == entry.xIndex)
            {
                while (m > 0 && _yVals[m - 1].xIndex == x)
                {
                    m -= 1
                }
                
                return m
            }
            
            if (x > entry.xIndex)
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
                let closestXIndex = _yVals[closest].xIndex
                if closestXIndex < x && closest < _yVals.count - 1
                {
                    closest = closest + 1
                }
            }
            else if rounding == .Down
            {
                let closestXIndex = _yVals[closest].xIndex
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
        for i in 0 ..< _yVals.count
        {
            if _yVals[i] === e
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
        let val = e.value
        
        if (_yVals == nil)
        {
            _yVals = [ChartDataEntry]()
        }
        
        if (_yVals.count == 0)
        {
            _yMax = val
            _yMin = val
        }
        else
        {
            if (_yMax < val)
            {
                _yMax = val
            }
            if (_yMin > val)
            {
                _yMin = val
            }
        }
        
        _yVals.append(e)
        
        return true
    }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to their appropriate index respective to it's x-index.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    /// - returns: true
    public override func addEntryOrdered(e: ChartDataEntry) -> Bool
    {
        let val = e.value
        
        if (_yVals == nil)
        {
            _yVals = [ChartDataEntry]()
        }
        
        if (_yVals.count == 0)
        {
            _yMax = val
            _yMin = val
        }
        else
        {
            if (_yMax < val)
            {
                _yMax = val
            }
            if (_yMin > val)
            {
                _yMin = val
            }
        }
        
        if _yVals.last?.xIndex > e.xIndex
        {
            var closestIndex = entryIndex(xIndex: e.xIndex, rounding: .Closest)
            if _yVals[closestIndex].xIndex < e.xIndex
            {
                closestIndex += 1
            }
            _yVals.insert(e, atIndex: closestIndex)
            
            return true
        }
        
        _yVals.append(e)
        
        return true
    }
    
    /// Removes an Entry from the DataSet dynamically.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter entry: the entry to remove
    /// - returns: true if the entry was removed successfully, else if the entry does not exist
    public override func removeEntry(entry: ChartDataEntry) -> Bool
    {
        var removed = false
        
        for i in 0 ..< _yVals.count
        {
            if (_yVals[i] === entry)
            {
                _yVals.removeAtIndex(i)
                removed = true
                break
            }
        }
        
        if (removed)
        {
            calcMinMax(start: _lastStart, end: _lastEnd)
        }
        
        return removed
    }
    
    /// Removes the first Entry (at index 0) of this DataSet from the entries array.
    ///
    /// - returns: true if successful, false if not.
    public override func removeFirst() -> Bool
    {
        let entry: ChartDataEntry? = _yVals.isEmpty ? nil : _yVals.removeFirst()
        
        let removed = entry != nil
        
        if (removed)
        {
            calcMinMax(start: _lastStart, end: _lastEnd)
        }
        
        return removed;
    }
    
    /// Removes the last Entry (at index size-1) of this DataSet from the entries array.
    ///
    /// - returns: true if successful, false if not.
    public override func removeLast() -> Bool
    {
        let entry: ChartDataEntry? = _yVals.isEmpty ? nil : _yVals.removeLast()
        
        let removed = entry != nil
        
        if (removed)
        {
            calcMinMax(start: _lastStart, end: _lastEnd)
        }
        
        return removed;
    }
    
    /// Checks if this DataSet contains the specified Entry.
    /// - returns: true if contains the entry, false if not.
    public override func contains(e: ChartDataEntry) -> Bool
    {
        for entry in _yVals
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
        _yVals.removeAll(keepCapacity: true)
        _lastStart = 0
        _lastEnd = 0
        notifyDataSetChanged()
    }
    
    // MARK: - Data functions and accessors
    
    /// - returns: the number of entries this DataSet holds.
    public var valueCount: Int { return _yVals.count }

    // MARK: - NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! ChartDataSet
        
        copy._yVals = _yVals
        copy._yMax = _yMax
        copy._yMin = _yMin
        copy._lastStart = _lastStart
        copy._lastEnd = _lastEnd

        return copy
    }
}


