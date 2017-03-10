//
//  ChartDataSet.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

/// Determines how to round DataSet index values for `ChartDataSet.entryIndex(x, rounding)` when an exact x-value is not found.
@objc
public enum ChartDataSetRounding: Int
{
    case up = 0
    case down = 1
    case closest = 2
}

/// The DataSet class represents one group or type of entries (Entry) in the Chart that belong together.
/// It is designed to logically separate different groups of values inside the Chart (e.g. the values for a specific line in the LineChart, or the values of a specific group of bars in the BarChart).
open class ChartDataSet: ChartBaseDataSet
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
    open var values: [ChartDataEntry]
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
    open override func notifyDataSetChanged()
    {
        calcMinMax()
    }
    
    open override func calcMinMax()
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
    
    open override calcMinMaxY(fromX: Double, toX: Double)
    {
        if _values.count == 0
        {
            return
        }
        
        _yMax = -DBL_MAX
        _yMin = DBL_MAX
        
        let indexFrom = entryIndex(x: fromX, closestToY: Double.nan, rounding: .down)
        let indexTo = entryIndex(x: toX, closestToY: Double.nan, rounding: .up)
        
        if indexTo < indexFrom { return }
        
        for i in indexFrom...indexTo
        {
            // only recalculate y
            calcMinMaxY(entry: _values[i])
        }
    }
    
    open func calcMinMaxX(entry e: ChartDataEntry)
    {
        if e.x < _xMin
        {
            _xMin = e.x
        }
        if e.x > _xMax
        {
            _xMax = e.x
        }
    }
    
    open func calcMinMaxY(entry e: ChartDataEntry)
    {
        if e.y < _yMin
        {
            _yMin = e.y
        }
        if e.y > _yMax
        {
            _yMax = e.y
        }
    }
    
    /// Updates the min and max x and y value of this DataSet based on the given Entry.
    ///
    /// - parameter e:
    internal func calcMinMax(entry e: ChartDataEntry)
    {
        calcMinMaxX(entry: e)
        calcMinMaxY(entry: e)
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
    open override var entryCount: Int { return _values?.count ?? 0 }
    
    /// - returns: The entry object found at the given index (not x-value!)
    /// - throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    open override func entryForIndex(_ i: Int) -> ChartDataEntry?
    {
        guard i >= 0 && i < _values.count else {
            return nil
        }
        return _values[i]
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
            return _values[index]
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
        closestToY yValue: Double) -> ChartDataEntry?
    {
        return entryForXValue(xValue, closestToY: yValue, rounding: .closest)
    }
    
    /// - returns: All Entry objects found at the given xIndex with binary search.
    /// An empty array if no Entry object at that index.
    open override func entriesForXValue(_ xValue: Double) -> [ChartDataEntry]
    {
        var entries = [ChartDataEntry]()
        
        var low = 0
        var high = _values.count - 1
        
        while low <= high
        {
            var m = (high + low) / 2
            var entry = _values[m]
            
            // if we have a match
            if xValue == entry.x
            {
                while m > 0 && _values[m - 1].x == xValue
                {
                    m -= 1
                }
                
                high = _values.count
                
                // loop over all "equal" entries
                while m < high
                {
                    entry = _values[m]
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
        var low = 0
        var high = _values.count - 1
        var closest = high
        
        while low < high
        {
            let m = (low + high) / 2
            
            let d1 = _values[m].x - xValue
            let d2 = _values[m + 1].x - xValue
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
            let closestXValue = _values[closest].x
            
            if rounding == .up
            {
                // If rounding up, and found x-value is lower than specified x, and we can go upper...
                if closestXValue < xValue && closest < _values.count - 1
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
                while closest > 0 && _values[closest - 1].x == closestXValue
                {
                    closest -= 1
                }
                
                var closestYValue = _values[closest].y
                var closestYIndex = closest
                
                while true
                {
                    closest += 1
                    if closest >= _values.count { break }
                    
                    let value = _values[closest]
                    
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
    /// - returns: True
    open override func addEntry(_ e: ChartDataEntry) -> Bool
    {
        if _values == nil
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
    /// - returns: True
    open override func addEntryOrdered(_ e: ChartDataEntry) -> Bool
    {
        if _values == nil
        {
            _values = [ChartDataEntry]()
        }
        
        calcMinMax(entry: e)
        
        if _values.count > 0 && _values.last!.x > e.x
        {
            var closestIndex = entryIndex(x: e.x, closestToY: e.y, rounding: .up)
            while _values[closestIndex].x < e.x
            {
                closestIndex += 1
            }
            _values.insert(e, at: closestIndex)
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
    /// - returns: `true` if the entry was removed successfully, else if the entry does not exist
    open override func removeEntry(_ entry: ChartDataEntry) -> Bool
    {
        var removed = false
        
        for i in 0 ..< _values.count
        {
            if _values[i] === entry
            {
                _values.remove(at: i)
                removed = true
                break
            }
        }
        
        if removed
        {
            calcMinMax()
        }
        
        return removed
    }
    
    /// Removes the first Entry (at index 0) of this DataSet from the entries array.
    ///
    /// - returns: `true` if successful, `false` ifnot.
    open override func removeFirst() -> Bool
    {
        let entry: ChartDataEntry? = _values.isEmpty ? nil : _values.removeFirst()
        
        let removed = entry != nil
        
        if removed
        {
            calcMinMax()
        }
        
        return removed
    }
    
    /// Removes the last Entry (at index size-1) of this DataSet from the entries array.
    ///
    /// - returns: `true` if successful, `false` ifnot.
    open override func removeLast() -> Bool
    {
        let entry: ChartDataEntry? = _values.isEmpty ? nil : _values.removeLast()
        
        let removed = entry != nil
        
        if removed
        {
            calcMinMax()
        }
        
        return removed
    }
    
    /// Checks if this DataSet contains the specified Entry.
    /// - returns: `true` if contains the entry, `false` ifnot.
    open override func contains(_ e: ChartDataEntry) -> Bool
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
    open override func clear()
    {
        _values.removeAll(keepingCapacity: true)
        notifyDataSetChanged()
    }
    
    // MARK: - Data functions and accessors

    // MARK: - NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! ChartDataSet
        
        copy._values = _values
        copy._yMax = _yMax
        copy._yMin = _yMin

        return copy
    }
}


